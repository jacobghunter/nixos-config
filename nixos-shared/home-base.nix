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
      EDITOR = "nvim";
    };

    modules.zsh = {
      enable = true;
    };

    modules.tinty = {
      enable = true;
    };

    # `rebuild` / `rebuild-boot` with no args rebuild the current machine
    # locally. With a host arg (e.g. `rebuild nixos-pihole`), they build
    # here and deploy to that host over ssh instead - no local sudo needed
    # since --use-remote-sudo handles activation on the target (relies on
    # passwordless sudo there, e.g. nixos-pihole's wheelNeedsPassword=false).
    programs.zsh.initContent = ''
      rebuild() {
        if [ -z "$1" ]; then
          sudo nixos-rebuild switch --flake ~/nixos-config
        else
          nixos-rebuild switch --flake ~/nixos-config#"$1" --target-host "jacob@$1" --use-remote-sudo
        fi
      }

      rebuild-boot() {
        if [ -z "$1" ]; then
          sudo nixos-rebuild boot --flake ~/nixos-config
        else
          nixos-rebuild boot --flake ~/nixos-config#"$1" --target-host "jacob@$1" --use-remote-sudo
        fi
      }
    '';

    home.shellAliases = {
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

    home.packages = with pkgs; [
      vim
      net-tools

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
