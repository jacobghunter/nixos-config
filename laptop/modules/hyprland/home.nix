{ lib, ... }:

{
  imports = [
    ../../../shared/modules/hyprland/home.nix
  ];

  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    monitor=,highres,auto,1
  '';
}
