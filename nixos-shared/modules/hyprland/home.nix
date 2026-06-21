{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
# battery format without percentage number in icon
# "format": "<span font='Material Symbols Rounded' size='18750' letter_spacing='-44000'>{icon}</span>",
# "format-charging": "<span font='Material Symbols Rounded' size='18750' letter_spacing='-44000'>{icon}</span>",
# "format-plugged": "<span font='Material Symbols Rounded' size='18750' letter_spacing='-44000'>{icon}</span>",

let
  palette = import "${inputs.self}/nixos-shared/palette.nix" { };

  primary = palette.primary + palette.alpha;
  secondary = palette.secondary + palette.alpha;
  special = palette.special + palette.alpha;
  gradientDegrees = "45";
  inactive = palette.inactive + palette.alpha-inactive;
  background = palette.background + palette.alpha-bg;
  text = palette.text + palette.alpha-inactive;
  shadow = palette.shadow + palette.alpha-inactive;

  # Waybar specific colors
  waybar-bg = palette.waybar-bg + palette.alpha-waybar;
  waybar-active = primary;
  waybar-focused = "eba0acee";
  waybar-urgent = "a6e3a1ee";
  waybar-hover = "cdd6f4ee";
  waybar-dark = palette.waybar-dark + palette.alpha-waybar;
  waybar-trough = palette.waybar-trough + palette.alpha-waybar;

  borderSize = palette.borderSize;
  borderRadius = palette.borderRadius;

  #### Hyprland helpers
  toRgbaDef = s: "rgba(" + s + ")";
  toDegrees = s: s + "deg";

  #### Rofi helpers
  toRgbHex = s: "#" + builtins.substring 0 6 s;
  addPx = s: s + "px";

  # Wallpapers
  staticWallpaper = "${inputs.self}/assets/backgrounds/outer-wilds.png";
  # videoWallpaper = "${inputs.self}/assets/backgrounds/outer-wilds.mp4";

  cursorTheme = "Bibata-Modern-Classic";
  cursorSize = 24;
  cursorPackage = pkgs.bibata-cursors;

  cfg = config.modules.hyprland;

  hdrFixPlugin =
    pkgs.callPackage "${inputs.self}/nixos-shared/modules/hyprland/hyprland-fix-hdr-screenshare.nix"
      {
        hyprlandPackage = pkgs.hyprland;
      };
in
{
  options.modules.hyprland = {
    # enableVideoWallpaper = lib.mkOption {
    #   type = lib.types.bool;
    #   default = false;
    #   description = "Whether to enable video wallpaper (mpvpaper).";
    # };
    enableWallpaperEngine = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Wallpaper Engine (linux-wallpaperengine).";
    };
    wallpaperEngineId = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The Steam Workshop ID of the Wallpaper Engine wallpaper to run.";
    };
    wallpaperEngineMap = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Map of monitor names to Wallpaper Engine IDs (takes precedence over wallpaperEngineId).";
    };
    wallpaperEngineFps = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "Max frame rate for Wallpaper Engine.";
    };
    idleTimeout = lib.mkOption {
      type = lib.types.int;
      default = 150;
      description = "Idle timeout in seconds before locking the screen.";
    };
    dpmsTimeout = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "Idle timeout in seconds before turning off the screen.";
    };
  };

  imports = [
    ./wallpaper.nix
    ./workspaces.nix
    ./menus.nix
  ];

  config = {

    modules.kitty.enable = true;

    home.sessionVariables = {
      HYPRCURSOR_THEME = cursorTheme;
      HYPRCURSOR_SIZE = toString cursorSize;
      XCURSOR_THEME = cursorTheme;
      XCURSOR_SIZE = toString cursorSize;
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      BROWSER = "firefox";
      DEFAULT_BROWSER = "firefox";
    };

    home.packages = with pkgs; [
      hyprpolkitagent
      wl-clipboard
      jgmenu
      tofi
      awww
      # mpvpaper
      linux-wallpaperengine
      jq
      wlogout
      grimblast
      hyprpicker
      hyprshot
      cliphist
      nautilus
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      package = pkgs.hyprland;
      systemd.enable = true;
      plugins = [
        hdrFixPlugin
        inputs.hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
        inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system}.split-monitor-workspaces
        inputs.hyprland-easymotion.packages.${pkgs.stdenv.hostPlatform.system}.hyprland-easymotion
      ];
      extraConfig =
        builtins.replaceStrings
          [
            "/usr/lib/polkit-kde-authentication-agent-1"
          ]
          [
            "systemctl --user start hyprpolkitagent"
          ]
          (builtins.readFile "${inputs.self}/nixos-shared/modules/hyprland/hyprland.conf");
      settings = {
        env = [
          "GTK_THEME,Adwaita:dark"
        ];
      };
    };

    # Scripts are now factored out and imported via ./workspaces.nix and ./wallpaper.nix

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

    # wifi_jgmenu.sh script is now factored out and imported via ./menus.nix

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
      theme = "${inputs.self}/nixos-shared/modules/hyprland/rofi-theme.rasi";
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

    home.pointerCursor = {
      gtk.enable = true;
      package = cursorPackage;
      name = cursorTheme;
      size = cursorSize;
      x11.enable = true; # Helper to keep X11 apps consistent
    };

    gtk = {
      enable = true;
      gtk4.theme = config.gtk.theme;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
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
            timeout = cfg.idleTimeout;
            on-timeout = "hyprlock";
          }
          {
            timeout = cfg.dpmsTimeout;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
          }
          {
            timeout = cfg.dpmsTimeout + 900;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
