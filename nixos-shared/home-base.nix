{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
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
    # since --elevate=sudo handles activation on the target (relies on
    # passwordless sudo there, e.g. nixos-pihole's wheelNeedsPassword=false).
    programs.zsh.initContent = ''
      rebuild() {
        if [ -z "$1" ]; then
          sudo nixos-rebuild switch --flake ~/nixos-config "$@"
        else
          local host="$1"
          shift
          nixos-rebuild switch --flake ~/nixos-config#"$host" --target-host "jacob@$host" --elevate=sudo "$@"
        fi
      }

      rebuild-boot() {
        if [ -z "$1" ]; then
          sudo nixos-rebuild boot --flake ~/nixos-config "$@"
        else
          local host="$1"
          shift
          nixos-rebuild boot --flake ~/nixos-config#"$host" --target-host "jacob@$host" --elevate=sudo "$@"
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

    # Base SSH aliases for the fleet, kept out of ~/.ssh/config itself so
    # personal/work entries there (added by hand, not tracked here) stay
    # untouched. Requires one manual one-time line at the END of
    # ~/.ssh/config: `Include ~/.ssh/conf.d/*.conf` - putting it at the end
    # means anything defined earlier in that file wins (ssh_config uses
    # first-match-wins), so hand-written entries can still override these.
    home.file.".ssh/conf.d/nixos-hosts.conf".text = ''
      Host nixos-laptop
        HostName nixos-laptop.local
        User jacob

      Host nixos-pc
        HostName nixos-pc.local
        User jacob

      Host nixos-server
        HostName nixos-server.local
        User jacob

      Host nixos-wsl
        HostName nixos-wsl.local
        User jacob

      Host nixos-pihole
        HostName nixos-pihole.local
        User jacob
    '';

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
