{ lib, inputs, ... }:

{
  imports = [
    "${inputs.self}/nixos-shared/modules/hyprland/home.nix"
  ];

  modules.hyprland.idleTimeout = 150; # 2.5 minutes
  modules.hyprland.dpmsTimeout = 300; # 5 minutes

  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    monitor=,preferred,auto,1,mirror,DP-1
  '';
}
