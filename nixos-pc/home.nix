{
  self,
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    "${self}/nixos-shared/modules/audio/disable-audio-devices.nix"
  ];

  modules.wayle.showBattery = false;
  modules.btop.package = pkgs.btop-rocm;

  home.packages = with pkgs; [
    nvtopPackages.amd
  ];

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

  modules.audioDeviceDisable = {
    nodeNames = [
      "alsa_output.usb-Samson_Technologies_Samson_Q2U_Microphone-00.analog-stereo"
    ];
    deviceNames = [
      "alsa_card.pci-0000_10_00.6" # motherboard HD Audio
      "alsa_card.pci-0000_03_00.1" # GPU Navi 31 HDMI/DP audio
      "alsa_card.pci-0000_10_00.1" # GPU Radeon HD audio
    ];
  };

  systemd.user.services.wayle = {
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
