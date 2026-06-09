{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  palette = import "${inputs.self}/nixos-shared/palette.nix" { };

  primary = palette.primary + palette.alpha;
  secondary = palette.secondary + palette.alpha;
  inactive = palette.inactive + palette.alpha-inactive;
  background = palette.background + palette.alpha-bg;
  text = palette.text + palette.alpha-inactive;

  # Waybar specific colors
  waybar-bg = palette.waybar-bg + palette.alpha-waybar;
  waybar-active = primary;
  waybar-focused = "eba0acee";
  waybar-urgent = "a6e3a1ee";
  waybar-hover = "cdd6f4ee";
  waybar-dark = palette.waybar-dark + palette.alpha-waybar;
  waybar-trough = palette.waybar-trough + palette.alpha-waybar;

  toRgbHex = s: "#" + builtins.substring 0 6 s;
in {
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
}
