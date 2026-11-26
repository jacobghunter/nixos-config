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
    # HEVC output is what makes 4K fit under RemoteClientBitrateLimit. ~2.6x
    # realtime at 4K on the UHD 630. Jellyfin (10.11) only encodes 8-bit Main
    # here, even when the client asks for main10 + HDR10.
    AllowHevcEncoding = "true";
    # HDR -> SDR via OpenCL on the GPU (intel-compute-runtime-legacy1). Every
    # HDR transcode gets tonemapped whatever the client supports - with this
    # off, 8-bit output would carry the HDR picture untonemapped instead.
    EnableTonemapping = "true";
    EnableDecodingColorDepth10Hevc = "true";
    EnableDecodingColorDepth10Vp9 = "true";
    # Pause transcodes that are far enough ahead, and clean up old segments.
    EnableThrottling = "true";
    EnableSegmentDeletion = "true";
    # Becomes hevc_vaapi -compression_level 7. The UHD 630 only accepts levels
    # 1, 4 and 7 - slower/slow/fast/faster (2, 3, 5, 6) fail every transcode
    # with "Error encoding a frame: Input/output error". medium (4) only runs
    # ~1x at 4K next to a second stream, so veryfast keeps two streams working.
    EncoderPreset = "veryfast";
    # Everything the UHD 630 can decode (no AV1 on Gen9).
    HardwareDecodingCodecs = [
      "h264"
      "hevc"
      "mpeg2video"
      "vc1"
      "vp8"
      "vp9"
    ];
  };

  # system.xml (Dashboard -> Playback -> Streaming).
  serverSettings = {
    # Bits/s, per stream - enough for 4K HEVC. Anything over it gets a
    # (hardware) transcode down to fit. jellyfin-bitrate-share below lowers it
    # per user when other remote streams are already using the upload.
    RemoteClientBitrateLimit = "20000000";
  };

  # Total upload (~30 Mbps) shared between remote streams, less some headroom.
  remoteUploadBudget = 28000000;
  # Lowest per-user limit handed out - still a watchable 1080p.
  remoteBitrateFloor = 8000000;

  # network.xml (Dashboard -> Networking).
  networkSettings = {
    # Caddy fronts the public domain, so trust its X-Forwarded-For - otherwise
    # every remote client shows up as 127.0.0.1, counts as LAN, and skips
    # RemoteClientBitrateLimit.
    KnownProxies = [ "127.0.0.1" ];
  };

  # Sets just the given keys in one of Jellyfin's config XMLs. String values
  # become element text, lists become <string> children.
  applySettings = pkgs.writeText "jellyfin-apply-settings.py" ''
    import json
    import os
    import sys
    import xml.etree.ElementTree as ET

    path, root_tag, settings = sys.argv[1], sys.argv[2], json.loads(sys.argv[3])
    ET.register_namespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")
    ET.register_namespace("xsd", "http://www.w3.org/2001/XMLSchema")

    if os.path.exists(path):
        tree = ET.parse(path)
    else:
        # Fresh install: Jellyfin fills in every other option with its defaults.
        tree = ET.ElementTree(ET.Element(root_tag))
    root = tree.getroot()

    def child(tag):
        el = root.find(tag)
        if el is None:
            el = ET.SubElement(root, tag)
        return el

    for tag, value in settings.items():
        el = child(tag)
        # Unset options are written as <Tag xsi:nil="true" />.
        el.attrib.pop("{http://www.w3.org/2001/XMLSchema-instance}nil", None)
        if isinstance(value, list):
            for old in list(el):
                el.remove(old)
            el.text = None
            for item in value:
                ET.SubElement(el, "string").text = item
        else:
            el.text = value

    ET.indent(tree, space="  ")
    tree.write(path, encoding="utf-8", xml_declaration=True)
  '';

  applyTo = file: rootTag: settings: ''
    ${lib.getExe pkgs.python3} ${applySettings} ${configDir}/${file} ${rootTag} \
      ${lib.escapeShellArg (builtins.toJSON settings)}
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
  # its config XMLs).
  systemd.services.jellyfin.preStart = ''
    mkdir -p ${configDir}
    ${applyTo "encoding.xml" "EncodingOptions" encodingSettings}
    ${applyTo "system.xml" "ServerConfiguration" serverSettings}
    ${applyTo "network.xml" "NetworkConfiguration" networkSettings}
  '';

  # Splits remoteUploadBudget between remote streams (see bitrate-share.py):
  # first remote viewer gets RemoteClientBitrateLimit, the next gets what's
  # left. Needs an API key (Dashboard -> API Keys) in /etc/jellyfin-bitrate.env
  # as JELLYFIN_API_KEY=..., root-only - like /etc/cloudflare.env.
  systemd.services.jellyfin-bitrate-share = {
    description = "Share upload bandwidth between remote Jellyfin streams";
    after = [ "jellyfin.service" ];
    wants = [ "jellyfin.service" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      JELLYFIN_URL = "http://127.0.0.1:8096";
      TOTAL_BITRATE = toString remoteUploadBudget;
      MAX_BITRATE = serverSettings.RemoteClientBitrateLimit;
      FLOOR_BITRATE = toString remoteBitrateFloor;
      POLL_SECONDS = "5";
    };
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.python3} -u ${./bitrate-share.py}";
      EnvironmentFile = "/etc/jellyfin-bitrate.env";
      DynamicUser = true;
      Restart = "always";
      RestartSec = 10;
    };
  };
}
