{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    "${inputs.self}/nixos-shared/modules/neovim/neovim.nix"
    "${inputs.self}/nixos-shared/modules/zsh/zsh.nix"
    "${inputs.self}/nixos-shared/modules/tinty/tinty.nix"
  ];

  options = {
    modules.btop.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.btop;
      description = "The btop package to install.";
    };
  };

  config = {
    home.username = "jacob";
    home.homeDirectory = "/home/jacob";
    home.stateVersion = "24.11";

    programs.home-manager.enable = true;

    home.sessionVariables = {
      EDITOR = "code --wait";
      BROWSER = "firefox";
      DEFAULT_BROWSER = "firefox";
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      PATH = "$HOME/.npm-global/bin:$PATH";
      GTK_THEME = "Adwaita:dark"; # Force dark mode for GTK/Electron/Chrome applications
    };

    modules.zsh = {
      enable = true;
    };

    modules.tinty = {
        enable = true;
    };

    home.shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
      rebuild-boot = "sudo nixos-rebuild boot --flake ~/nixos-config";
      ll = "eza -l --git";
      gs = "git status";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gprune = "git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d";
      nf = "fzf -m --preview='bat --color=always {}' --bind 'enter:become(nvim {+})'";

      # Tool replacements
      ls = "eza";
      grep = "rg";
      cat = "bat";
      find = "fd";
      ps = "procs";
      fuck = "f";
      copy = "wl-copy";
    };

    programs.git = {
      enable = true;
      signing.format = "openpgp";
      settings.user = {
        name = "Jacob Hunter";
        email = "jacobguinhunter@gmail.com";
      };
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f";
    };

    # Replaces cd
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    # Environment variable manager for project directories
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true; # Enables the faster, caching Nix integration
    };

    # Replaces zsh history
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
    };

    programs.pay-respects = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    home.packages = with pkgs; [
      vim

      # Dev Tools
      nodejs
      lua
      pnpm
      python3
      gcc
      gnumake
      net-tools
      inputs.antigravity-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default

      # Tool replacements
      # grep
      ripgrep
      # ls
      eza
      # ps
      procs
      # find
      fd
      # top
      config.modules.btop.package
      # cat
      bat
      # tmux
      zellij
      # du
      dust

      # Utilities
      jq
      tldr
      zip
      unzip
      tree
    ];
  };
}
