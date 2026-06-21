{ lib, inputs, ... }:

{
  imports = [
    "${inputs.self}/nixos-shared/modules/hyprland/home.nix"
  ];

  modules.hyprland.enableWallpaperEngine = true;
  modules.hyprland.wallpaperEngineMap = {
    "DP-1" = "2557395646"; # First monitor
    "HDMI-A-1" = "2984500160"; # Second monitor
  };

  modules.hyprland.idleTimeout = 600; # 10 minutes
  modules.hyprland.dpmsTimeout = 900; # 15 minutes

  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    # PC monitor configuration (simplified for debugging)
    monitor=HDMI-A-1,2560x1440@59.95,0x0,1

    monitorv2 {
        output = DP-1
        mode = 3440x1440@174.96
        position = 2560x0
        scale = 1
        bitdepth = 10
        cm = hdr
        sdrbrightness = 2
        sdrsaturation = 1.1
        sdr_min_luminance = 0.005
        vrr = 2
    }
  '';
}
