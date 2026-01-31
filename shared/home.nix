{ config, pkgs, ... }:

{
  # --- SHARED ENVIRONMENT VARIABLES ---
  home.sessionVariables = {
    EDITOR = "code --wait";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    PATH = "$HOME/.npm-global/bin:$PATH";
  };

  # --- SHARED SHELL CONFIGURATION (ZSH) ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    initContent = ''
      # disable sort when completing `git checkout`
      zstyle ':completion:*:git-checkout:*' sort false
      # set descriptions format to enable group support
      zstyle ':completion:*:descriptions' format '[%d]'
      # set list-colors to enable filename colorizing
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
      ];
      theme = "robbyrussell";
    };
  };

  # --- SHARED ALIASES ---
  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
    ll = "ls -l";
    gs = "git status";
    ga = "git add";
    gc = "git commit -m";
    gp = "git push";
  };

  # --- SHARED GIT CONFIGURATION ---
  programs.git = {
    enable = true;
    settings.user = {
      name = "Jacob Hunter";
      email = "jacobguinhunter@gmail.com";
    };
  };

  # --- SHARED PACKAGES ---
  # Utilities common to both laptop and server
  home.packages = with pkgs; [
    # Dev Tools
    nodejs
    pnpm
    python3
    gcc
    gnumake
    gemini-cli
    
    # Utilities
    ripgrep
    jq
    fzf
    btop
    zip
    unzip
  ];
}
