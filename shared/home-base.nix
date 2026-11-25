{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    "${inputs.self}/shared/modules/zsh/zsh.nix"
    "${inputs.self}/shared/modules/tinty/tinty.nix"
  ];

  options = {
    modules.btop.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.btop;
      description = "The btop package to install.";
    };
  };

  config = {
    home = {
      username = "jacob";
      homeDirectory = "/home/jacob";
      stateVersion = "24.11";
      sessionVariables = {
        EDITOR = "nvim";
      };
      shellAliases = {
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

      packages = with pkgs; [
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

      # Base SSH aliases for the fleet, kept out of ~/.ssh/config itself so
      # personal/work entries there (added by hand, not tracked here) stay
      # untouched. Requires one manual one-time line at the END of
      # ~/.ssh/config: `Include ~/.ssh/conf.d/*.conf` - putting it at the end
      # means anything defined earlier in that file wins (ssh_config uses
      # first-match-wins), so hand-written entries can still override these.
      file.".ssh/conf.d/nixos-hosts.conf".text = ''
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

        Host tv
          HostName 192.168.1.223
          User root

        Host nixos-printer
          HostName nixos-printer.local
          User jacob

        # Tailscale IP: it lives on another network, so .local (mDNS) never
        # resolves from here or from the server that builds for it.
        Host nixos-parents
          HostName 100.71.38.51
          User jacob
      '';
    };

    programs = {
      home-manager.enable = true;

      # `rebuild` / `rebuild-boot` with no args rebuild the current machine
      # locally. With a host arg (e.g. `rebuild nixos-pihole`), they deploy to
      # that host over ssh - --elevate=sudo handles activation on the target.
      # Where the build runs depends on the host, so another machine's closure
      # never lands on (or streams through) this one:
      #   - nixos-pc, nixos-server: build on the target itself.
      #   - the Pis: build on nixos-server (fast, wired, emulates aarch64, has
      #     the attic cache), driven from the server so it copies straight to
      #     the Pi. nixos-rebuild's own --build-host would relay a
      #     remote-to-remote copy through this machine. --use-substitutes has
      #     the Pi fetch anything on cache.nixos.org itself, so only what the
      #     server built (config, the Pi kernel) crosses the home uplink.
      #   - anything else, or `--local` right after the host: build here.
      # The server is addressed by LAN IP so this works away from home too, via
      # its Tailscale subnet route.
      zsh.initContent = ''
        _nixos_deploy() {
          local action="$1"
          shift
          if [ -z "$1" ]; then
            sudo nixos-rebuild "$action" --flake ~/nixos-config
            return
          fi

          local host="$1"
          shift
          local builder=local
          if [ "$1" = "--local" ]; then
            shift
          else
            case "$host" in
              nixos-pc|nixos-server) builder=self ;;
              nixos-pihole|nixos-parents|nixos-printer) builder=server ;;
            esac
          fi

          case "$builder" in
            local)
              nixos-rebuild "$action" --flake ~/nixos-config#"$host" --target-host "jacob@$host" --elevate=sudo "$@"
              ;;
            self)
              nixos-rebuild "$action" --flake ~/nixos-config#"$host" --target-host "jacob@$host" --build-host "jacob@$host" --elevate=sudo "$@"
              ;;
            server)
              # Ship just this flake's source (a few hundred KB, uncommitted
              # changes included); the server fetches the locked inputs itself.
              local server=jacob@192.168.1.167 src
              src=$(nix flake metadata --json ~/nixos-config | jq -r .path) || return
              nix copy --to "ssh-ng://$server" "$src" || return
              ssh -t "$server" nixos-rebuild "$action" --flake "$src#$host" --target-host "jacob@$host" --elevate=sudo --use-substitutes "$@"
              ;;
          esac
        }

        rebuild() { _nixos_deploy switch "$@"; }
        rebuild-boot() { _nixos_deploy boot "$@"; }
      '';

      git = {
        enable = true;
        signing.format = "openpgp";
        settings.user = {
          name = "Jacob Hunter";
          email = "jacobguinhunter@gmail.com";
        };
      };

      fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultCommand = "fd --type f";
      };

      # Replaces cd
      zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [ "--cmd cd" ];
      };
    };

    modules = {
      zsh = {
        enable = true;
      };
      tinty = {
        enable = true;
      };
    };
  };
}
