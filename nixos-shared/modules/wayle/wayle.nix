{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  palette = import "${inputs.self}/nixos-shared/palette.nix" { };
  autohide = false; # Set to true for auto-hide mode, false for default mode
  dropdownMaxY = 550; # Height threshold (in pixels) for the dropdown zone
in
{
  services.wayle = {
    enable = true;
    settings = {
      bar = {
        exclusive = !autohide;
        bg = "transparent";
        button-border-location = "none";
        button-group-rounding = "lg";
        button-icon-size = 0.95;
        button-rounding = "lg";
        dropdown-freeze-label = false;
        dropdown-opacity = 95;
        inset-ends = 0.5;
        button-group-background = "bg-surface-elevated";
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
                name = "meta";
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
                name = "sys";
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
          icon-bg-color = "accent";
          label-color = "accent";
        };
        brightness = {
          right-click = "pgrep -x hyprsunset >/dev/null && pkill -x hyprsunset || hyprsunset -t 4500 &";
        };
        clock = {
          dropdown-show-seconds = true;
          icon-show = false;
        };
        dashboard = {
          border-color = "accent";
          icon-bg-color = "accent";
          dropdown-logout-command = "hyprctl dispatch exit";
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
          show-special = false;
        };
        volume = {
          scroll-up = "wayle audio output-volume +5";
          scroll-down = "wayle audio output-volume -5";
        };
        brightness = {
          scroll-up = "brightnessctl set +5%";
          scroll-down = "brightnessctl set 5%-";
        };
        network = {
          border-color = "green";
          icon-bg-color = "green";
          label-color = "green";
        };
        window-title = {
          icon-bg-color = "transparent";
          icon-color = "accent";
          label-color = "accent";
        };
        weather = {
          location = "Tucson";
          units = "imperial";
          border-color = "green";
          icon-bg-color = "green";
          label-color = "green";
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

  # Autohide script configuration
  xdg.configFile."hypr/scripts/wayle_autohide.sh" = lib.mkIf autohide {
    text = ''
      #!/usr/bin/env bash
      HYPRCTL="${config.wayland.windowManager.hyprland.package}/bin/hyprctl"
      WAYLE="wayle"

      visible=true
      # Start by showing the bar
      $WAYLE panel show 2>/dev/null

      hide_timer=0
      prev_pos=""

      while true; do
          pos=$($HYPRCTL cursorpos)
          y="''${pos##*, }"

          if [ "$y" -le 3 ]; then
              if [ "$visible" = false ]; then
                  $WAYLE panel show 2>/dev/null
                  visible=true
              fi
              hide_timer=0
          elif [ "$y" -le 60 ]; then
              # Hovering the bar itself
              hide_timer=0
          else
              # Y > 60 (below the bar)
              if [ "$visible" = true ]; then
                  if [ "$y" -gt ${toString dropdownMaxY} ]; then
                      # Mouse is way below (returned to active workspace area), hide immediately
                      $WAYLE panel hide 2>/dev/null
                      visible=false
                      hide_timer=0
                  else
                      # 60 < Y <= dropdownMaxY: potential dropdown zone
                      if [ "$pos" != "$prev_pos" ]; then
                          # Mouse is moving/interacting in the dropdown, reset timer
                          hide_timer=0
                      else
                          hide_timer=$((hide_timer + 1))
                      fi

                      # Hide after ~1.2s of no movement in the dropdown zone
                      if [ "$hide_timer" -ge 8 ]; then
                          $WAYLE panel hide 2>/dev/null
                          visible=false
                          hide_timer=0
                      fi
                  fi
              fi
          fi

          prev_pos="$pos"
          sleep 0.15
      done
    '';
    executable = true;
  };

  wayland.windowManager.hyprland.settings.exec-once = lib.optionals autohide [
    "~/.config/hypr/scripts/wayle_autohide.sh &"
  ];
}
