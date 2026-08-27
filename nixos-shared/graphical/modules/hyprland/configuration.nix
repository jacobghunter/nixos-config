{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # Binary Cache
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
        }/bin/start-hyprland";
        user = "jacob";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  # xdg-desktop-portal-hyprland is intentionally left out of extraPortals -
  # home-manager's wayland.windowManager.hyprland.systemd.enable (see home.nix)
  # already registers that portal's systemd user service, and having both
  # NixOS and home-manager manage it collides at build time (duplicate
  # xdg-desktop-portal-hyprland.service unit).
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [
      "hyprland"
      "gtk"
    ];
  };

  environment.sessionVariables = {
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    # SDDM Theme
    sddm-astronaut

    dunst
    kdePackages.dolphin
    hyprpaper
    pavucontrol
    networkmanagerapplet
    blueman
    brightnessctl
    playerctl
    gnome-calendar
  ];
}
