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
        dropdown-opacity = 95;
        inset-ends = 0.5;
        layout = [
          {
            center = [ "window-title" ];
            left = [
              {
                modules = [
                  "hyprland-workspaces"
                  "clock"
                  "weather"
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
      modules = {
        battery = {
          icon-show = false;
        };
        clock = {
          dropdown-show-seconds = true;
          icon-show = false;
        };
        weather = {
          location = "Tucson";
          units = "imperial";
        };
        hyprland-workspaces = {
          workspace-map = {
            "-99" = {
              label = "Special";
            };
            "-98" = {
              label = "★";
            };
          };
        };
        volume = {
          scroll-up = "wayle audio output-volume +5";
          scroll-down = "wayle audio output-volume -5";
        };
        brightness = {
          scroll-up = "brightnessctl set +5%";
          scroll-down = "brightnessctl set 5%-";
        };
        window-title = {
          icon-bg-color = "transparent";
          icon-color = "accent";
          label-color = "accent";
        };
        dashboard = {
          dropdown-logout-command = "hyprctl dispatch exit";
        };
      };
      styling = {
        palette = {
          bg = "#11111b";
          blue = "#74c7ec";
          elevated = "#1e1e2e";
          fg = "#cdd6f4";
          fg-muted = "#bac2de";
          green = "#a6e3a1";
          primary = "#${palette.primary}";
          red = "#f38ba8";
          surface = "#181825";
          yellow = "#f9e2af";
        };
        rounding = "md";
      };
    };
  };

  wayland.windowManager.hyprland.settings.exec-once = [ "wayle shell" ];
}
