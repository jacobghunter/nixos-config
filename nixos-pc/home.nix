{
  self,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    "${self}/nixos-shared/modules/audio/disable-audio-devices.nix"
  ];

  modules = {
    wayle.showBattery = false;
    btop.package = pkgs.btop-rocm;
    audioDeviceDisable = {
      nodeNames = [
        "alsa_output.usb-Samson_Technologies_Samson_Q2U_Microphone-00.analog-stereo"
      ];
      deviceNames = [
        "alsa_card.pci-0000_10_00.6" # motherboard HD Audio
        "alsa_card.pci-0000_03_00.1" # GPU Navi 31 HDMI/DP audio
        "alsa_card.pci-0000_10_00.1" # GPU Radeon HD audio
      ];
    };
  };

  home.packages = with pkgs; [
    nvtopPackages.amd
    (symlinkJoin {
      name = "orca-slicer";
      paths = [
        (appimageTools.wrapType2 {
          pname = "orca-slicer";
          version = "2.3.2";
          src = fetchurl {
            url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v2.3.2/OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.3.2.AppImage";
            sha256 = "1n2afc153fl1pxzif65z0921hkhjynmblp37drv43n9pxk73chy6";
          };
          extraPkgs =
            pkgs: with pkgs; [
              webkitgtk_4_1
              libsoup_3
              sqlite
              libmspack
              bzip2.out
            ];
        })
      ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/orca-slicer \
          --prefix LD_LIBRARY_PATH : "${bzip2.out}/lib"
      '';
    })
  ];

  xdg.configFile."OrcaSlicer/user/default" = {
    source = "${self}/configs/orca";
    recursive = true;
  };

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      legacy_layout = false;
      cpu_stats = true;
      gpu_stats = true;
      ram = true;
      vram = true;
      fps = true;
      frame_timing = true;
      frametime = true;

      # Logging hotkey and directory
      toggle_logging = "Shift_L+F2";
      output_folder = "/home/jacob/.local/share/mangohud";
    };
  };

  systemd.user.services.wayle = lib.mkIf config.modules.wayle.enable {
    Service = {
      # Wait up to 5 seconds for a default audio sink to be discovered by wireplumber
      # before starting wayle, to prevent the audio module from failing to initialize.
      ExecStartPre = pkgs.writeShellScript "wait-for-audio" ''
        for i in {1..25}; do
          if ${pkgs.wireplumber}/bin/wpctl inspect @DEFAULT_AUDIO_SINK@ >/dev/null 2>&1; then
            exit 0
          fi
          sleep 0.2
        done
      '';
    };
  };
}
