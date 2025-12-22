{
  pkgs,
  config,
  inputs,
  ...
}:

let
  primary = "ce00ffcc";
  secondary = "00dbffcc";
  gradientDegrees = "45";
  inactive = "595959ee";
  background = "1e1e2eee";
  text = "cdd6f4ee";
  shadow = "1a1a1aee";

  borderSize = "1";
  borderRadius = "10";

  #### Hyprland helpers
  toRgbaDef = s: "rgba(" + s + ")";
  toDegrees = s: s + "deg";

  #### Rofi helpers
  toRgbHex = s: "#" + builtins.substring 0 6 s;
  addPx = s: s + "px";
in
{
  home.sessionVariables = {
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    GTK_THEME = "Adwaita:dark";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  wayland.windowManager.hyprland.settings = {
    env = [
      "HYPRCURSOR_THEME,Bibata-Modern-Classic"
      "HYPRCURSOR_SIZE,24"
      "XCURSOR_THEME,Bibata-Modern-Classic"
      "XCURSOR_SIZE,24"
      "GTK_THEME,Adwaita:dark"
    ];
  };

  # 0. Scripts
  xdg.configFile."hypr/scripts/toggle_special.sh" = {
    text = ''
      #!/usr/bin/env bash
      JQ=${pkgs.jq}/bin/jq
      HYPRCTL=${config.wayland.windowManager.hyprland.package}/bin/hyprctl

      # Get current window info
      WINDOW_INFO=$($HYPRCTL activewindow -j)
      WORKSPACE=$(echo "$WINDOW_INFO" | $JQ -r '.workspace.name')

      if [ "$WORKSPACE" == "special:magic" ]; then
          # Move OUT to the active workspace of the current monitor
          MONITOR_ID=$(echo "$WINDOW_INFO" | $JQ -r '.monitor')
          TARGET=$( $HYPRCTL monitors -j | $JQ -r --argjson m "$MONITOR_ID" '.[] | select(.id == $m) | .activeWorkspace.name' )
          $HYPRCTL dispatch movetoworkspace "name:$TARGET"
      else
          # Move IN to special workspace
          $HYPRCTL dispatch movetoworkspace "special:magic"
      fi
    '';
    executable = true;
  };

  # 1. Generate Hyprland Variables
  xdg.configFile."hypr/variables.conf".text = ''
    # Hyprland gets the raw rgba values and the gradient logic
    $activeBorder = ${toRgbaDef primary} ${toRgbaDef secondary} ${toDegrees gradientDegrees}
    $inactiveBorder = ${toRgbaDef inactive}

    $shadow = ${toRgbaDef shadow}
    $borderSize = ${borderSize}
    $rounding = ${borderRadius}
  '';

  # 2. Generate Rofi Colors/Vars
  xdg.configFile."rofi/variables.rasi".text = ''
    /* Rofi gets the stripped HEX codes */
    * {
        main-bg:        ${toRgbHex background};
        main-fg:        ${toRgbHex text};
        
        accent-color:   ${toRgbHex primary};
        inactive-color: ${toRgbHex inactive};
        
        border-width:   ${addPx borderSize};
        radius:         ${addPx borderRadius};
    }
  '';

  # 3. Configure Rofi to use your static theme
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = ./rofi-theme.rasi;
    # extraConfig = {
    #   modi = "drun";
    #   show-icons = true;
    #   display-drun = "Apps";
    #   drun-display-format = "{icon} {name}";
    # };
  };

  xdg.configFile."waybar/variables.css".text = ''
    @define-color primary ${toRgbHex primary};
    @define-color secondary ${toRgbHex secondary};
    @define-color inactive ${toRgbHex inactive};
    @define-color background ${toRgbHex background};
    @define-color text ${toRgbHex text};
  '';

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 10;
    x11.enable = true; # Helper to keep X11 apps consistent
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
    };
  };

  # --- NEW: WAYBAR CONFIG ---
  programs.waybar = {
    enable = true;
    style = ''
      ${builtins.readFile ./waybar.css}

      window#waybar {
        border-radius: ${borderRadius}px;
      }

      window#waybar:hover {
        background: linear-gradient(${toRgbHex background}, ${toRgbHex background}) padding-box,
                    linear-gradient(to right, ${toRgbHex primary} 0%, ${toRgbHex secondary} 100%) border-box;
        border: 1px solid transparent;
        border-radius: ${borderRadius}px;
      }
    '';
    settings = {
      mainBar = builtins.fromJSON (builtins.readFile ./waybar.jsonc);
    };
  };

  # 4. Configure Hyprland to use your static config
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    systemd.enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  # 5. Screen Locking (Hyprlock)
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        no_fade_in = false;
        grace = 0;
        disable_loading_bar = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
  };

  # 6. Idle Management (Hypridle)
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "pidof hyprlock || hyprlock";
      };

      listener = [
        {
          timeout = 150;
          on-timeout = "hyprlock";
        }
        {
          timeout = 300;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
