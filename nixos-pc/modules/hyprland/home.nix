{ lib, ... }:

{
  imports = [
    ../../../nixos-shared/modules/hyprland/home.nix
  ];

  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    # PC monitor configuration (simplified for debugging)
    monitor=HDMI-A-1,2560x1440@59.97300,0x0,1
    monitor=DP-1,3440x1440@174.96,2560x0,1,bitdepth,10,cm,hdr,sdrbrightness,1.2,sdrsaturation,1.05,vrr,1
  '';
}
