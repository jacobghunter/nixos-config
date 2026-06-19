{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [ "${inputs.self}/nixos-shared/neovim.nix" ];

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

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = false;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "gitfast"
        "sudo"
      ];
      theme = "robbyrussell";
    };

    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting.src;
      }
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
          exec zellij attach -c
        fi
      fi

      # Insert Nth recent command at cursor (invoked by kitty keybindings)
      insert-nth-recent-command() {
        local idx
        if [[ "$KEYS" =~ '20([1-9])~' ]]; then
          idx="''${match[1]}"
        else
          idx=1
        fi
        local -a hist_keys
        hist_keys=(''${(nk)history})
        local cmd="$history[''${hist_keys[-$idx]}]"
        LBUFFER+="$cmd"
      }
      zle -N insert-nth-recent-command
      bindkey '\e[201~' insert-nth-recent-command
      bindkey '\e[202~' insert-nth-recent-command
      bindkey '\e[203~' insert-nth-recent-command
      bindkey '\e[204~' insert-nth-recent-command
      bindkey '\e[205~' insert-nth-recent-command
      bindkey '\e[206~' insert-nth-recent-command
      bindkey '\e[207~' insert-nth-recent-command
      bindkey '\e[208~' insert-nth-recent-command
      bindkey '\e[209~' insert-nth-recent-command

      # Wrapper for mangoplot with python dependencies
      mangoplot() {
        nix-shell -p "python3.withPackages (ps: with ps; [ numpy matplotlib ])" --run "mangoplot $*"
      }
    '';
  };

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
    ll = "eza -l --git";
    gs = "git status";
    ga = "git add";
    gc = "git commit -m";
    gp = "git push";
    gprune = "git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d";
    nf = "fzf -m --preview='bat --color=always {}' --bind 'enter:become(nvim {+})'";

    # Tool replacements
    cd = "z";
    cdi = "zi";
    ls = "eza";
    grep = "rg";
    cat = "bat";
    find = "fd";
    ps = "procs";
    fuck = "f";
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
    pnpm
    python3
    gcc
    gnumake
    net-tools
    inputs.antigravity-cli.packages.${pkgs.stdenv.hostPlatform.system}.default

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
