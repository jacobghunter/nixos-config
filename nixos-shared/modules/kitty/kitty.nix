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
in {
  options.modules.kitty = {
    enable = mkEnableOption "kitty";
    colors = {
      text = mkOption { type = types.str; default = palette.text; };
      background = mkOption { type = types.str; default = palette.waybar-bg; };
      primary = mkOption { type = types.str; default = palette.primary; };
      secondary = mkOption { type = types.str; default = palette.secondary; };
      inactive = mkOption { type = types.str; default = palette.inactive; };
      special = mkOption { type = types.str; default = palette.special; };
      dark = mkOption { type = types.str; default = palette.waybar-dark; };
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
        window_padding_width = 8;
        italic_font = "auto";
        bold_italic_font = "auto";
        disable_ligatures = "always";

        # Theming based on options
        foreground = "#${cfg.colors.text}";
        background = "#${cfg.colors.background}";
        selection_foreground = "#${cfg.colors.background}";
        selection_background = "#${cfg.colors.primary}";

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
    };
  };
}
