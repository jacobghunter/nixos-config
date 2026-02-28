{ config, pkgs, ... }:

{
  imports = [
    ../home.nix
  ];

  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "24.11";

  home.shellAliases = {
    hyprbinds = "cat ~/.config/hypr/hyprland.conf | grep bind";
  };

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
    spotify

    # Games
    heroic
    love

    # Dev Tools
    cmake

    # Electronics / Hardware
    kicad-small
  ];

  # --- PROGRAMS CONFIGURATION ---

  programs.home-manager.enable = true;

  # --- DEFAULT TO FIREFOX ---
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
