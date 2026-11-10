{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.modules.caelestia;
  shellJsonPath = "${config.home.homeDirectory}/nixos-config/shared/graphical/modules/caelestia/shell.json";

  # Caelestia has no per-host config layer, only per-monitor overrides
  # (~/.config/caelestia/monitors/<name>/shell.json). A list in an override
  # replaces the global list wholesale instead of merging, so the global
  # statusIcons are copied in here (at build time) with just battery disabled.
  monitorOverride = {
    bar.statusIcons = map (
      icon: if icon.id == "battery" then icon // { enabled = false; } else icon
    ) (lib.importJSON ./shell.json).bar.statusIcons;
  };

  # Caelestia writes runtime state back into shell.json itself (e.g. the VPN
  # tile saves utilities.vpn.enabled on every connect/disconnect, reformatting
  # the whole file as it goes), which tripped caelestia-config-reload and
  # restarted the shell mid-toggle. Only restart when the parsed settings
  # actually changed - ignoring formatting and the keys the shell owns.
  shellOwnedKeys = [ ".utilities.vpn.enabled" ];
  reloadIfChanged = pkgs.writeShellScript "caelestia-reload-if-changed" ''
    cache="''${XDG_RUNTIME_DIR:-/tmp}/caelestia-shell.json.normalized"
    new=$(${pkgs.jq}/bin/jq -S 'del(${lib.concatStringsSep ", " shellOwnedKeys})' "${shellJsonPath}") || exit 0
    if [ -f "$cache" ] && [ "$new" = "$(cat "$cache")" ]; then
      exit 0
    fi
    printf '%s' "$new" > "$cache"
    exec ${pkgs.systemd}/bin/systemctl --user try-restart caelestia.service
  '';
in
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  options.modules.caelestia = {
    enable = lib.mkEnableOption "the Caelestia desktop shell";

    showBattery = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to show the battery status icon in the bar. Without a laptop
        battery Caelestia turns it into a power-profile switcher, which is
        dead weight on a host without power-profiles-daemon.
      '';
    };

    hibernate = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether idle sleep (the caelestia-sleep command shell.json's idle
        timeouts call) uses suspend-then-hibernate or plain suspend. Waking
        from hibernation is a full cold boot, which buys nothing on a desktop
        without a battery to run flat.
      '';
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "DP-1" ];
      description = ''
        Monitor names (`hyprctl monitors -j | jq -r '.[].name'`) to write
        per-monitor overrides for - needed by showBattery, since Caelestia
        can only vary bar options per monitor, not per host.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (!cfg.enable) {
      # Left behind from a previous enable, hyprland.lua would otherwise keep
      # reading it as border colours even after switching to another shell.
      home.activation.removeCaelestiaScheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        rm -f "${config.xdg.configHome}/hypr/scheme/current.lua"
      '';
    })
    (lib.mkIf cfg.enable {
      # `caelestia shell <message...>` sends an IPC message to the running
      # shell (see daemons/Shortcuts.qml's `drawers` IpcHandler) - this is the
      # same mechanism the CLI's own launcher actions use, just invoked directly
      # so the shared Hyprland config doesn't need to know Caelestia's IPC shape.
      modules.activeShellLauncherCmd = "caelestia shell drawers toggle launcher";
      # Caelestia runs its own idle/lock/suspend (shell.json general.idle), so
      # hypridle would just lock a second time with hyprlock.
      modules.hyprland.hypridle.enable = false;

      # Caelestia has no polkit agent of its own (DMS does), and without one
      # GUI privilege prompts (udisks mounts, system NM connections) just fail.
      services.hyprpolkitagent.enable = true;

      # shell.json is shared by every host and has no per-host layer, so its
      # idle timeouts call this instead of systemctl directly.
      home.packages = [
        (pkgs.writeShellScriptBin "caelestia-sleep" ''
          exec ${pkgs.systemd}/bin/systemctl ${if cfg.hibernate then "suspend-then-hibernate" else "suspend"}
        '')
      ];

      programs.caelestia = {
        enable = true;
        systemd.enable = true;

        # Upstream picks the battery icon with Math.floor(percentage * 7), so
        # 37% shows battery_2_bar (~29% full). Round to the nearest bar
        # instead (37% -> battery_3_bar, ~43%); capped at 6 since there's no
        # battery_7_bar - 100% still gets battery_full via the check above it.
        # --replace-fail so an upstream rewrite breaks the build loudly
        # instead of silently dropping the patch.
        package =
          inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli.overrideAttrs
            (old: {
              postPatch = (old.postPatch or "") + ''
                substituteInPlace utils/Icons.qml \
                  --replace-fail "let level = Math.floor(percentage * 7);" \
                                 "let level = Math.min(6, Math.round(percentage * 7));"
              '';
            });

        # settings/extraConfig deliberately left unset: setting either makes
        # home-manager own shell.json as a read-only store symlink (no live
        # editing, no writes from the GUI below). Instead, shell.json is
        # symlinked straight to this module's own file (out-of-store), so
        # editing it - by hand or via the GUI - lands directly in this
        # git-tracked file, no rebuild needed to pick it up. See the
        # caelestia-config-reload path/service below for *why* it's picked up.

        cli = {
          enable = true;
          # `caelestia scheme set` pushes raw OSC terminal colour escapes to
          # every open pty (theme.py apply_terms), overwriting the ANSI
          # palette/fg/bg that tinty manages for zsh/nvim. This CLI config
          # (its own file, unrelated to shell.json) turns off just that step.
          settings.theme.enableTerm = false;
        };
      };

      assertions = [
        {
          assertion = cfg.showBattery || cfg.monitors != [ ];
          message = "modules.caelestia.showBattery = false needs modules.caelestia.monitors set.";
        }
      ];

      xdg.configFile = {
        "caelestia/shell.json".source = config.lib.file.mkOutOfStoreSymlink shellJsonPath;
      }
      // lib.optionalAttrs (!cfg.showBattery) (
        lib.listToAttrs (
          map (
            monitor:
            lib.nameValuePair "caelestia/monitors/${monitor}/shell.json" {
              text = builtins.toJSON monitorOverride;
              # Same atomic-replace problem as shell.json below: a rebuild swaps
              # the symlink, which Caelestia's watcher doesn't notice.
              onChange = "${pkgs.systemd}/bin/systemctl --user try-restart caelestia.service";
            }
          ) cfg.monitors
        )
      );

      systemd.user = {
        # Caelestia's own file watcher (QFileSystemWatcher on the literal
        # ~/.config/caelestia/shell.json path) doesn't survive an editor's
        # atomic rename-over-save on the real file: the watched inode dies with
        # the rename, and the directory-level fallback watches
        # ~/.config/caelestia/, not this repo's directory where the rename
        # actually happens - so reload silently stops working until something
        # restarts the process. There's no IPC reload command to paper over it
        # (checked caelestia-shell's source: none exists). This path unit
        # watches the real repo file directly and restarts the shell whenever
        # it changes, so no manual restart is needed either.
        paths.caelestia-config-reload = {
          Unit.Description = "Watch Caelestia's shell.json for changes";
          Path.PathModified = shellJsonPath;
          Install.WantedBy = [ "default.target" ];
        };

        # `caelestia scheme set` rewrites hypr/scheme/current.lua (see
        # hyprland.lua, which reads it for border colours) but has no way to
        # tell Hyprland to re-read it - hyprctl reload is the only mechanism,
        # and Hyprland doesn't watch that file itself.
        paths.caelestia-scheme-reload = {
          Unit.Description = "Watch Caelestia's Hyprland colour scheme for changes";
          Path.PathModified = "${config.xdg.configHome}/hypr/scheme/current.lua";
          Install.WantedBy = [ "default.target" ];
        };

        services = {
          # The launcher spawns apps as plain children (DesktopEntry.execute), so
          # they land in caelestia.service's cgroup - and the default
          # KillMode=control-group takes Steam/Discord/etc. down with every shell
          # restart, including the config-reload one below. Only kill the shell.
          caelestia.Service.KillMode = "process";

          caelestia-config-reload = {
            Unit.Description = "Restart Caelestia shell after shell.json changes";
            Service = {
              Type = "oneshot";
              ExecStart = "${reloadIfChanged}";
            };
          };

          caelestia-scheme-reload = {
            Unit.Description = "Reload Hyprland after Caelestia's colour scheme changes";
            Service = {
              Type = "oneshot";
              ExecStart = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl reload";
            };
          };
        };
      };
    })
  ];
}
