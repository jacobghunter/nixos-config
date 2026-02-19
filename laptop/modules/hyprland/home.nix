{
  pkgs,
  config,
  inputs,
  ...
}:
# battery format without percentage number in icon
# "format": "<span font='Material Symbols Rounded' size='18750' letter_spacing='-44000'>{icon}</span>",
# "format-charging": "<span font='Material Symbols Rounded' size='18750' letter_spacing='-44000'>{icon}</span>",
# "format-plugged": "<span font='Material Symbols Rounded' size='18750' letter_spacing='-44000'>{icon}</span>",

let
  primary = "ce00ffcc";
  secondary = "00dbffcc";
  special = "fb42b6cc";
  gradientDegrees = "45";
  inactive = "595959ee";
  background = "000000b3";
  text = "cdd6f4ee";
  shadow = "1a1a1aee";

  # Waybar specific colors
  waybar-bg = "1e1e2eee";
  waybar-active = primary;
  waybar-focused = "eba0acee";
  waybar-urgent = "a6e3a1ee";
  waybar-hover = "cdd6f4ee";
  waybar-dark = "11111bee";
  waybar-trough = "313244ee";

  borderSize = "1";
  borderRadius = "10";

  #### Hyprland helpers
  toRgbaDef = s: "rgba(" + s + ")";
  toDegrees = s: s + "deg";

  #### Rofi helpers
  toRgbHex = s: "#" + builtins.substring 0 6 s;
  addPx = s: s + "px";

  # Wallpapers
  staticWallpaper = "${config.xdg.configHome}/assets/backgrounds/outer-wilds.png";
  videoWallpaper = "${config.xdg.configHome}/assets/backgrounds/outer-wilds.mp4";
in
{
  home.sessionVariables = {
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  home.packages = with pkgs; [
    hyprpolkitagent
    wl-clipboard
    jgmenu
    tofi
    swww
    mpvpaper
    wlogout
    grimblast
    hyprpicker
    cliphist
    nautilus
  ];

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

  xdg.configFile."hypr/scripts/power_monitor.sh" = {
    text = ''
      #!/usr/bin/env bash

      # Paths injected from nix
      STATIC_WALLPAPER="${staticWallpaper}"
      VIDEO_WALLPAPER="${videoWallpaper}"

      # Function to set static wallpaper
      set_static() {
          if pgrep "mpvpaper" > /dev/null; then
              killall mpvpaper
          fi
          # Ensure swww is running
          if ! pgrep "swww-daemon" > /dev/null; then
              swww-daemon &
              sleep 0.5
          fi
          swww img "$STATIC_WALLPAPER" --transition-type none
      }

      # Function to set video wallpaper
      set_video() {
          # Video wallpaper disabled by user request (performance)
          # if ! pgrep "mpvpaper" > /dev/null; then
          #     killall swww-daemon 2>/dev/null
          #     mpvpaper -o "no-audio loop" '*' "$VIDEO_WALLPAPER" > /dev/null 2>&1 &
          # fi
          set_static
      }

      # Check power state function
      check_power() {
          # Common names are AC, AC0, ADP0, ADP1. We'll search for one starting with A.
          AC_SUPPLY=$(ls /sys/class/power_supply/ | grep -E "^(AC|ADP)" | head -n 1)

          if [ -z "$AC_SUPPLY" ]; then
              set_static
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

  xdg.configFile."jgmenu/jgmenurc".text = ''
    tint2_look = 0
    shades_of_gray = 0
    font = JetBrainsMono Nerd Font 12
    icon_theme = Papirus
    color_menu_bg = ${toRgbHex waybar-bg} 100
    color_menu_border = ${toRgbHex primary} 100
    color_norm_fg = ${toRgbHex text} 100
    color_sel_bg = ${toRgbHex primary} 100
    color_sel_fg = ${toRgbHex waybar-bg} 100
    color_sep_fg = ${toRgbHex inactive} 100
    menu_margin_x = 10
    menu_margin_y = 30
    menu_padding_top = 5
    menu_padding_right = 5
    menu_padding_bottom = 5
    menu_padding_left = 5
    menu_radius = 10
    menu_border = 2
    menu_halign = right
    menu_valign = top
    sub_hover_action = 1
  '';

  xdg.configFile."hypr/scripts/wifi_jgmenu.sh" = {
    text = ''
      #!/usr/bin/env bash

      # Generate menu content
      {
          echo "<b>Wi-Fi Networks</b>,^sep()"
          
          # Use cached results (remove --rescan yes) for instant rendering
          nmcli -t -f SSID,SECURITY,BARS,ACTIVE device wifi list | awk -F: '!seen[$1]++' | while IFS=: read -r ssid security bars active; do
              if [[ -z "$ssid" ]]; then continue; fi
              
              display_text="$ssid"
              if [[ "$active" == "yes" ]]; then
                  display_text="<b>* $ssid</b>"
              fi
              
              # Escape quotes in SSID for the command
              safe_ssid=$(echo "$ssid" | sed 's/"/\\"/g')
              
              # jgmenu format: Label, command
              echo "$display_text  <small>($bars)</small>,nmcli device wifi connect \"$safe_ssid\" && notify-send \"Connected to $safe_ssid\""
          done

          echo "^sep()"
          echo "  Rescan Networks,notify-send 'Scanning...' && nmcli device wifi list --rescan yes && notify-send 'Scan Complete' 'Re-open menu to see new networks'"
          echo "Open Connection Editor,nm-connection-editor"
      } | jgmenu --simple --at-pointer
    '';
    executable = true;
  };

  # 1. Generate Hyprland Variables
  xdg.configFile."hypr/variables.conf".text = ''
    # Hyprland gets the raw rgba values and the gradient logic
    $activeBorder = ${toRgbaDef primary} ${toRgbaDef secondary} ${toDegrees gradientDegrees}
    $specialBorder = ${toRgbaDef primary} ${toRgbaDef special} ${toDegrees gradientDegrees}
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

  # 3. Rofi Config
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = ./rofi-theme.rasi;
  };

  # Tofi Configs
  xdg.configFile."tofi/configA".text = ''
    width = 100%
    height = 100%
    border-width = 0
    outline-width = 0
    padding-left = 33%
    padding-top = 33%
    result-spacing = 25
    num-results = 5
    font = JetBrainsMono Nerd Font
    font-size = 24
    text-color = ${toRgbHex text}
    prompt-text = " : "
    background-color = ${toRgbHex waybar-dark}d9
    selection-color = ${toRgbHex secondary}
  '';

  xdg.configFile."tofi/configV".text = ''
    width = 100%
    height = 100%
    border-width = 0
    outline-width = 0
    padding-top = 33%
    padding-left = 10%
    padding-right = 10%
    result-spacing = 25
    num-results = 5
    font = JetBrainsMono Nerd Font
    font-size = 24
    text-color = ${toRgbHex text}
    prompt-text = "Clipboard: "
    background-color = ${toRgbHex waybar-dark}d9
    selection-color =  ${toRgbHex secondary}
  '';

  # Wlogout Configs
  xdg.configFile."wlogout/layout".text = ''
    {
        "label" : "exit",
        "action" : "",
        "text" : "Exit",
        "keybind" : "h"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shutdown",
        "keybind" : "s"
    }
    {
        "label" : "suspend",
        "action" : "systemctl suspend-then-hibernate",
        "text" : "Suspend",
        "keybind" : "u"
    }
    {
        "label" : "lock",
        "action" : "hyprlock",
        "text" : "Lock",
        "keybind" : "l"
    }
    {
        "label" : "logout",
        "action" : "hyprctl dispatch exit",
        "text" : "Logout",
        "keybind" : "e"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r"
    }
  '';

  xdg.configFile."wlogout/style.css".text =
    builtins.replaceStrings
      [ "/usr/local/share/wlogout/icons" ]
      [ "${pkgs.wlogout}/share/wlogout/icons" ]
      ''
        * {
            font-family: JetBrains Mono, Symbols Nerd Font;
            font-size: 24px;
            transition-property: background-color;
            transition-duration: 0.7s;
        }

        window {
            background-color: ${toRgbHex waybar-dark};
            /* border-radius: 10px; */
        }

        button {
            background-color: ${toRgbHex waybar-dark};
            border-style: solid;
            /* border-width: 2px; */
            border-radius: 50px;
            background-repeat: no-repeat;
            background-position: center;
            background-size: 15%;
            margin: 15px;
        }

        button:active,
        button:hover {
            background-color: ${toRgbHex text};
        }

        button:focus {
            background-color: ${toRgbHex text};
        }

        #lock {
            background-image: image(url("../assets/wlogout/assets/lock.png"), url("/usr/local/share/wlogout/icons/lock.png"));
        }

        #lock:hover {
            background-image: image(url("../assets/wlogout/assets/lock-hover.png"), url("/usr/local/share/wlogout/icons/lock.png"));
            color: ${toRgbHex waybar-dark};
        }

        #logout {
            background-image: image(url("../assets/wlogout/assets/logout.png"), url("/usr/local/share/wlogout/icons/logout.png"));
        }

        #logout:hover {
            background-image: image(url("../assets/wlogout/assets/logout-hover.png"), url("/usr/local/share/wlogout/icons/logout.png"));
            color: ${toRgbHex waybar-dark};
        }

        #suspend {
            background-image: image(url("../assets/wlogout/assets/sleep.png"), url("/usr/local/share/wlogout/icons/suspend.png"));
        }

        #suspend:hover {
            background-image: image(url("../assets/wlogout/assets/sleep-hover.png"), url("/usr/local/share/wlogout/icons/suspend.png"));
            color: ${toRgbHex waybar-dark};
        }

        #shutdown {
            background-image: image(url("../assets/wlogout/assets/power.png"), url("/usr/local/share/wlogout/icons/shutdown.png"));
        }

        #shutdown:hover {
            background-image: image(url("../assets/wlogout/assets/power-hover.png"), url("/usr/local/share/wlogout/icons/shutdown.png")); 
            color: ${toRgbHex waybar-dark};
        }

        #reboot {
            background-image: image(url("../assets/wlogout/assets/restart.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
        }

        #reboot:hover {
            background-image: image(url("../assets/wlogout/assets/restart-hover.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
            color: ${toRgbHex waybar-dark};
        }

        #exit {
            background-image: image(url("../assets/wlogout/assets/restart.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
            background-color: ${toRgbHex waybar-dark};

        }

        #exit:hover {
            background-image: image(url("../assets/wlogout/assets/restart-hover.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
            color: ${toRgbHex waybar-dark};
            background-color: ${toRgbHex text};
        }
      '';

  xdg.configFile."waybar/variables.css".text = ''
    @define-color primary ${toRgbHex primary};
    @define-color secondary ${toRgbHex secondary};
    @define-color inactive ${toRgbHex inactive};
    @define-color background ${toRgbHex background};
    @define-color text ${toRgbHex text};

    /* Waybar specific */
    @define-color waybar-bg ${toRgbHex waybar-bg};
    @define-color waybar-active ${toRgbHex waybar-active};
    @define-color waybar-focused ${toRgbHex waybar-focused};
    @define-color waybar-urgent ${toRgbHex waybar-urgent};
    @define-color waybar-hover ${toRgbHex waybar-hover};
    @define-color waybar-dark ${toRgbHex waybar-dark};
    @define-color waybar-trough ${toRgbHex waybar-trough};
  '';

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };
    settings = {
      window_padding_width = 8;
      italic_font = "auto";
      bold_italic_font = "auto";

      # Theming based on nix variables
      foreground = toRgbHex text;
      background = toRgbHex waybar-bg;
      selection_foreground = toRgbHex waybar-bg;
      selection_background = toRgbHex primary;

      cursor = toRgbHex secondary;
      cursor_text_color = toRgbHex waybar-bg;

      url_color = toRgbHex secondary;

      active_border_color = toRgbHex primary;
      inactive_border_color = toRgbHex inactive;
      bell_border_color = toRgbHex special;

      active_tab_foreground = toRgbHex waybar-bg;
      active_tab_background = toRgbHex primary;
      inactive_tab_foreground = toRgbHex text;
      inactive_tab_background = toRgbHex waybar-dark;
      tab_bar_background = toRgbHex waybar-dark;
      term = "xterm-256color";
    };
  };

  programs.waybar = {
    enable = true;
    style = ''
      @import "variables.css";
      ${builtins.readFile ./waybar.css}
    '';
    settings = {
      mainBar = builtins.fromJSON (builtins.readFile ./waybar.jsonc);
    };
  };

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
    };
  };

  xdg.configFile."assets/backgrounds/README.md".text = ''
    # Wallpapers
    Place your wallpaper images here.
    The config expects a file named 'cat_leaves.png' by default.
  '';

  # 4. Configure Hyprland to use your static config
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    systemd.enable = true;
    extraConfig =
      builtins.replaceStrings
        [
          "/usr/lib/polkit-kde-authentication-agent-1"
          "/usr/bin/dunst"
          "thorium-browser"
        ]
        [
          "systemctl --user start hyprpolkitagent"
          "dunst" # Assumed in PATH
          "firefox"
        ]
        (builtins.readFile ./hyprland.conf);
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
        after_sleep_cmd = "hyprctl dispatch dpms on && brightnessctl -r";
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
          on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
        }
      ];
    };
  };
}
