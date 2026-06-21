{ lib, inputs, ... }:

{
  imports = [
    "${inputs.self}/nixos-shared/modules/hyprland/home.nix"
  ];

  modules.hyprland.idleTimeout = 150; # 2.5 minutes
  modules.hyprland.dpmsTimeout = 300; # 5 minutes

  services.hypridle.settings.general.after_sleep_cmd = "hyprctl dispatch dpms on && brightnessctl -r && (sleep 8 && systemctl --user restart wayle.service &)";

  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    monitor=,preferred,auto,1,mirror,DP-1
  '';
}
