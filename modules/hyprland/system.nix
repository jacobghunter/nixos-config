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
    wayland.enable = false;
    package = pkgs.libsForQt5.sddm;
    theme = "sugar-dark";
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
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    # SDDM Theme
    sddm-sugar-dark
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtsvg

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
