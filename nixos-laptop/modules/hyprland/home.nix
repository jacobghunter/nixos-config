{ lib, ... }:

{
  imports = [
    ../../../nixos-shared/modules/hyprland/home.nix
  ];

  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    monitor=,preferred,auto,1,mirror,DP-1
  '';
}
