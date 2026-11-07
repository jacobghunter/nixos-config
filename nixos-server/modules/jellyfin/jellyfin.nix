{
  pkgs,
  lib,
  ...
}:
let
  configDir = "/var/lib/jellyfin/config";

  # Transcoding settings pinned in encoding.xml on every start, so they survive
  # a wipe of the server. Values are Jellyfin's own element names/strings.
  #
  # Not using services.jellyfin.{hardwareAcceleration,transcoding} +
  # forceEncodingConfig: that replaces the whole file whenever it differs, and
  # Jellyfin fills in its own defaults on every start, so it backs up + rewrites
  # every restart. Its template also writes codec names like "mpeg2" (Jellyfin
  # matches "mpeg2video", so MPEG-2 hw decode silently never enables) and never
  # writes EnableSegmentDeletion. This only touches the keys below and leaves
  # the rest editable from the dashboard.
  encodingSettings = {
    # UHD 630 (i5-8500): VA-API rather than QSV - jellyfin-ffmpeg's oneVPL
    # runtime doesn't support Gen9 without the legacy Media SDK runtime.
    HardwareAccelerationType = "vaapi";
    VaapiDevice = "/dev/dri/renderD128";
    EnableHardwareEncoding = "true";
    # HDR -> SDR via OpenCL on the GPU (intel-compute-runtime-legacy1).
    EnableTonemapping = "true";
    EnableDecodingColorDepth10Hevc = "true";
    EnableDecodingColorDepth10Vp9 = "true";
    # Pause transcodes that are far enough ahead, and clean up old segments.
    EnableThrottling = "true";
    EnableSegmentDeletion = "true";
  };
  # Everything the UHD 630 can decode (no AV1 on Gen9).
  hardwareDecodingCodecs = [
    "h264"
    "hevc"
    "mpeg2video"
    "vc1"
    "vp8"
    "vp9"
  ];

  applyEncodingSettings = pkgs.writeText "jellyfin-encoding-settings.py" ''
    import json
    import os
    import sys
    import xml.etree.ElementTree as ET

    path, settings, codecs = sys.argv[1], json.loads(sys.argv[2]), json.loads(sys.argv[3])
    ET.register_namespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")
    ET.register_namespace("xsd", "http://www.w3.org/2001/XMLSchema")

    if os.path.exists(path):
        tree = ET.parse(path)
    else:
        # Fresh install: Jellyfin fills in every other option with its defaults.
        tree = ET.ElementTree(ET.Element("EncodingOptions"))
    root = tree.getroot()

    def child(tag):
        el = root.find(tag)
        if el is None:
            el = ET.SubElement(root, tag)
        return el

    for tag, value in settings.items():
        child(tag).text = value

    codec_list = child("HardwareDecodingCodecs")
    for el in list(codec_list):
        codec_list.remove(el)
    for codec in codecs:
        ET.SubElement(codec_list, "string").text = codec

    ET.indent(tree, space="  ")
    tree.write(path, encoding="utf-8", xml_declaration=True)
  '';
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-ocl
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      intel-compute-runtime-legacy1
    ];
  };

  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jellyfin";
  };

  # Runs as the jellyfin user before the server starts (and so before it reads
  # encoding.xml).
  systemd.services.jellyfin.preStart = ''
    mkdir -p ${configDir}
    ${lib.getExe pkgs.python3} ${applyEncodingSettings} ${configDir}/encoding.xml \
      ${lib.escapeShellArg (builtins.toJSON encodingSettings)} \
      ${lib.escapeShellArg (builtins.toJSON hardwareDecodingCodecs)}
  '';
}
