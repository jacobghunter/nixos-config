{ lib, inputs, ... }:

{
  imports = [
    "${inputs.self}/nixos-shared/modules/hyprland/home.nix"
  ];

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
        sdrbrightness = 1.8
        sdrsaturation = 1.25
        sdr_min_luminance = 0.005
        vrr = 2
    }
  '';
}
