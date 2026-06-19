{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

with lib;

let
  cfg = config.modules.kitty;
  palette = import "${inputs.self}/nixos-shared/palette.nix" { };
in
{
  options.modules.kitty = {
    enable = mkEnableOption "kitty";
    colors = {
      text = mkOption {
        type = types.str;
        default = palette.text;
      };
      background = mkOption {
        type = types.str;
        default = palette.waybar-bg;
      };
      primary = mkOption {
        type = types.str;
        default = palette.primary;
      };
      secondary = mkOption {
        type = types.str;
        default = palette.secondary;
      };
      inactive = mkOption {
        type = types.str;
        default = palette.inactive;
      };
      special = mkOption {
        type = types.str;
        default = palette.special;
      };
      dark = mkOption {
        type = types.str;
        default = palette.waybar-dark;
      };
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono NF";
        size = 13;
      };
      settings = {
        auto_reload_config = -1;
        window_padding_width = 8;
        italic_font = "auto";
        bold_italic_font = "auto";
        disable_ligatures = "always";
        enabled_layouts = "tall,stack";

        # Resizing settings for hyprland
        resize_debounce_time = 0;
        placement_strategy = "top-left";
        resize_draw_strategy = "scale";
        linux_display_server = "wayland";

        # Theming based on options
        foreground = "#${cfg.colors.text}";
        background = "#${cfg.colors.background}";
        selection_foreground = "#${cfg.colors.background}";
        selection_background = "#${cfg.colors.primary}";

        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";

        cursor = "#${cfg.colors.secondary}";
        cursor_text_color = "#${cfg.colors.background}";

        url_color = "#${cfg.colors.secondary}";

        active_border_color = "#${cfg.colors.primary}";
        inactive_border_color = "#${cfg.colors.inactive}";
        bell_border_color = "#${cfg.colors.special}";

        active_tab_foreground = "#${cfg.colors.background}";
        active_tab_background = "#${cfg.colors.primary}";
        inactive_tab_foreground = "#${cfg.colors.text}";
        inactive_tab_background = "#${cfg.colors.dark}";
        tab_bar_background = "#${cfg.colors.dark}";
        term = "xterm-256color";
      };
      keybindings = {
        "kitty_mod+h" = "kitty_scrollback_nvim";
        "kitty_mod+g" = "kitty_scrollback_nvim --config ksb_builtin_last_cmd_output";
        "kitty_mod+p" = "kitten hints --program @";
        "kitty_mod+o" = "kitten hints --type path --program @";
        "kitty_mod+i" = "kitten hints --type word --program @";
        "kitty_mod+u" = "kitten hints --type hash --program @";
        "kitty_mod+y" = "kitten hints --type line --program @";
        "kitty_mod+enter" = "launch --cwd=current --location=hsplit";
        "kitty_mod+f" = "toggle_layout stack";
        "kitty_mod+a" = "move_window_forward";
        "kitty_mod+d" = "move_window_backward";
        "kitty_mod+shift+q" = "detach_window ask";
        "backspace" = "send_text all \\x7f";
        "kitty_mod+1" = "send_text all \\x1b[201~";
        "kitty_mod+2" = "send_text all \\x1b[202~";
        "kitty_mod+3" = "send_text all \\x1b[203~";
        "kitty_mod+4" = "send_text all \\x1b[204~";
        "kitty_mod+5" = "send_text all \\x1b[205~";
        "kitty_mod+6" = "send_text all \\x1b[206~";
        "kitty_mod+7" = "send_text all \\x1b[207~";
        "kitty_mod+8" = "send_text all \\x1b[208~";
        "kitty_mod+9" = "send_text all \\x1b[209~";
      };
      extraConfig = ''
        action_alias kitty_scrollback_nvim kitten ${config.home.homeDirectory}/.local/share/nvim/lazy/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py
        mouse_map kitty_mod+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
      '';
    };
  };
}
