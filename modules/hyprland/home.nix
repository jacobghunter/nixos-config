{ pkgs, config, ... }:

let
  # --- YOUR DESIGN TOKENS ---
  primary = "33ccffee";
  secondary = "00ff99ee";
  inactive = "595959ee";
  background = "1e1e2eee";
  text = "cdd6f4ee";
  shadow = "1a1a1aee";

  borderSize = "1";
  borderRadius = "10";

  # Give the hyperland supported format
  toRgbaDef = s: "rgba(" + s + ")";
  # Strip rgba to rgb and make it hex
  toRgbHex = s: "#" + builtins.substring 0 6 s;
  # Helper to add "px" for rofi
  addPix = s: s + "px";
in
{
  # 1. Generate Hyprland Variables
  xdg.configFile."hypr/variables.conf".text = ''
    # Hyprland gets the raw rgba values and the gradient logic
    $activeBorder = ${toRgbaDef primary} ${toRgbaDef secondary} 45deg
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
        
        border-width:   ${addPix borderSize};
        radius:         ${addPix borderRadius};
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

  # 4. Configure Hyprland to use your static config
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
