{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  palette = import "${inputs.self}/nixos-shared/palette.nix" { };
in
{
  services.wayle = {
    enable = true;
    settings = {
      bar = {
        bg = "transparent";
        button-border-location = "none";
        button-group-rounding = "lg";
        button-icon-size = 0.95;
        button-rounding = "lg";
        dropdown-freeze-label = false;
        dropdown-opacity = 85;
        inset-ends = 0.5;
        layout = [
          {
            center = [ "window-title" ];
            left = [
              {
                modules = [
                  "clock"
                  "weather"
                  "hyprland-workspaces"
                ];
                name = "group";
              }
            ];
            monitor = "*";
            right = [
              {
                modules = [
                  "brightness"
                  "volume"
                ];
                name = "controls";
              }
              {
                modules = [
                  "bluetooth"
                  "network"
                ];
                name = "connections";
              }
              {
                modules = [
                  "systray"
                  "battery"
                  "dashboard"
                ];
                name = "group";
              }
            ];
            show = true;
          }
        ];
        module-gap = 1;
        padding = 0.25;
        rounding = "lg";
        scale = 0.9;
      };
      styling = {
        rounding = "md";
      };
    };
  };
}
