# ~/nixos-config/home.nix
{ config, pkgs, ... }:

{
  imports = [
    ../shared/home.nix
  ];

  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "24.11";

  # --- ALIASES ---
  home.shellAliases = {
    hyprbinds = "cat ~/.config/hypr/hyprland.conf | grep bind";
  };

  # --- USER PACKAGES ---
  # Laptop specific packages
  home.packages = with pkgs; [
    # Applications
    firefox
    vscode
    brave
    discord
    obsidian
    bitwarden-desktop
    remmina
    copyq
    calibre

    # Games
    heroic
    love

    # Dev Tools (Moved shared ones to shared/home.nix)
    cmake

    # Electronics / Hardware
    qmk
    kicad-small

    # Utilities (Moved shared ones to shared/home.nix)
    powerstat
    upower
  ];

  # --- PROGRAMS CONFIGURATION ---
  
  programs.home-manager.enable = true;

  # --- DEFAULT APPS (XDG MIME) ---
  # Replaces xdg.mime.defaultApplications from your old config
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
