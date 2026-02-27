{ config, pkgs, ... }:

{
  imports = [ ./neovim.nix ];
  # --- SHARED ENVIRONMENT VARIABLES ---
  home.sessionVariables = {
    EDITOR = "code --wait";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    PATH = "$HOME/.npm-global/bin:$PATH";
  };

  # --- SHARED SHELL CONFIGURATION (ZSH) ---
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
      theme = "robbyrussell";
    };

    plugins = [
      # Your fzf-tab config
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      # These are sourced directly from nixpkgs for reliability
      {
        name = "you-should-use";
        src = pkgs.zsh-you-should-use.src;
      }
      {
        name = "zsh-z";
        src = pkgs.zsh-z.src;
      }
      {
        name = "zsh-bat";
        src = pkgs.fetchFromGitHub {
          owner = "fdellwing";
          repo = "zsh-bat";
          rev = "master";
          sha256 = "0sj8dwqlnd7dz7djs6kv92vsxqai2sc2pq865r7i5lxgjxk9hfsd";
        };
      }
    ];

    initContent = ''
      # disable sort when completing `git checkout`
      zstyle ':completion:*:git-checkout:*' sort false
      # set descriptions format to enable group support
      zstyle ':completion:*:descriptions' format '[%d]'
      # set list-colors to enable filename colorizing
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Automatically start zellij on SSH
      if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$ZELLIJ" ]]; then
        if command -v zellij >/dev/null 2>&1; then
          zellij
        fi
      fi
    '';
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
    bat
    zellij
    tree 
  ];
}
