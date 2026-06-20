{ pkgs, config, lib, inputs, ... }:

let
  cfg = config.modules.hyprland;
  staticWallpaper = "${inputs.self}/assets/backgrounds/outer-wilds.png";
  # videoWallpaper = "${inputs.self}/assets/backgrounds/outer-wilds.mp4";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "wpe-list" (builtins.readFile ./scripts/wpe-list.sh))
    (pkgs.writeShellScriptBin "wpe-apply" (builtins.readFile ./scripts/wpe-apply.sh))
  ];

  xdg.configFile."hypr/scripts/power_monitor.sh" = {
    text = ''
      #!/usr/bin/env bash

      # Paths injected from nix
      STATIC_WALLPAPER="${staticWallpaper}"
      WORKSHOP_DIR="$HOME/.steam/steam/steamapps/workshop/content/431960"

      # Function to set static wallpaper
      set_static() {
          # if pgrep "mpvpaper" > /dev/null; then
          #     killall mpvpaper
          # fi
          if pgrep "linux-wallpaperengine" > /dev/null; then
              killall linux-wallpaperengine
          fi
          # Ensure awww is running
          if ! pgrep "awww-daemon" > /dev/null; then
              awww-daemon &
              sleep 0.5
          fi
          awww img "$STATIC_WALLPAPER" --transition-type none
      }

      # Function to set video wallpaper
      set_video() {
          ${if cfg.enableWallpaperEngine then ''
              if [ -d "$WORKSHOP_DIR" ]; then
                  if ! pgrep "linux-wallpaperengine" > /dev/null; then
                      killall awww-daemon 2>/dev/null
                      ${if cfg.wallpaperEngineMap != {} then ''
                          linux-wallpaperengine --silent --fps ${toString cfg.wallpaperEngineFps} --scaling stretch ${
                            lib.concatStringsSep " " (
                              lib.mapAttrsToList (monitor: id: "--screen-root ${monitor} --bg \"$WORKSHOP_DIR/${id}\"") cfg.wallpaperEngineMap
                            )
                          } > /dev/null 2>&1 &
                      '' else ''
                          if [ -d "$WORKSHOP_DIR/${cfg.wallpaperEngineId}" ]; then
                              ARGS=""
                              for monitor in $(hyprctl monitors -j | jq -r '.[] | .name'); do
                                  ARGS="$ARGS --screen-root $monitor --bg $WORKSHOP_DIR/${cfg.wallpaperEngineId}"
                              done
                              linux-wallpaperengine --silent --fps ${toString cfg.wallpaperEngineFps} --scaling stretch $ARGS > /dev/null 2>&1 &
                          else
                              set_static
                          fi
                      ''}
                  fi
              else
                  set_static
              fi
          '' else ''
              set_static
          ''}
      }

      # Check power state function
      check_power() {
          # Common names are AC, AC0, ADP0, ADP1. We'll search for one starting with A.
          AC_SUPPLY=$(ls /sys/class/power_supply/ | grep -E "^(AC|ADP)" | head -n 1)

          if [ -z "$AC_SUPPLY" ]; then
              set_video
              return
          fi

          STATUS=$(cat /sys/class/power_supply/$AC_SUPPLY/online)

          if [ "$STATUS" = "1" ]; then
              set_video
          else
              set_static
          fi
      }

      # Initial check
      check_power

      # Event loop using upower
      upower --monitor | while read -r line; do
          # We only care if the line-power changed or battery state changed significantly
          # But simpler to just re-check on any upower event.
          check_power
      done
    '';
    executable = true;
  };

  xdg.configFile."hypr/scripts/doom-eternal-wrapper.sh" = {
    source = ./scripts/doom-eternal-wrapper.sh;
    executable = true;
  };

  systemd.user.services.power-monitor = {
    Unit = {
      Description = "Power Monitor Wallpaper Service";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${config.xdg.configHome}/hypr/scripts/power_monitor.sh";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
