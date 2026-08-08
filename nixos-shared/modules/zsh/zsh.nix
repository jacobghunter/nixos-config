{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = {
    enable = lib.mkEnableOption "Enable zsh shell";
  };

  config = lib.mkIf cfg.enable {
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
        # if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$ZELLIJ" ]]; then
        #   if command -v zellij >/dev/null 2>&1; then
        #     exec zellij attach -c
        #   fi
        # fi

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
  };
}
