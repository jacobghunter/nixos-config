{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # Binary Cache
  # nix.settings = {
  #   substituters = [ "https://hyprland.cachix.org" ];
  #   trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  # };

  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    wayland.enable = false;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      sddm-astronaut
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qt5compat
    ];
  };

  services.displayManager.defaultSession = "hyprland";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.sessionVariables = {
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    # SDDM Theme
    sddm-astronaut

    kitty
    waybar
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

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
