# ~/nixos-config/home.nix
{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "24.11";

  # --- ENVIRONMENT VARIABLES ---
  home.sessionVariables = {
    EDITOR = "code --wait";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    PATH = "$HOME/.npm-global/bin:$PATH";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  # --- ALIASES ---
  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
    hyperbinds = "cat ~/.config/hypr/hyprland.conf | grep bind";
    ll = "ls -l";
    gs = "git status";
    ga = "git add";
    gc = "git commit -m";
    gp = "git push";
  };

  # --- USER PACKAGES ---
  # Everything you use day-to-day goes here
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

    # Dev Tools
    nodejs
    python3
    gcc
    gnumake
    cmake
    gemini-cli

    # Electronics / Hardware
    qmk
    kicad-small

    # Utilities
    ripgrep
    jq
    fzf
    btop
    zip
    unzip
  ];

  # --- PROGRAMS CONFIGURATION ---

  programs.git = {
    enable = true;
    userName = "Jacob Hunter";
    userEmail = "jacobguinhunter@gmail.com"; # <--- Don't forget to set this!
  };

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
