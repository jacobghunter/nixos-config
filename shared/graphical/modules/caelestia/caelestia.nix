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
  monitorOverrideFile = pkgs.writeText "caelestia-monitor-override.json" (
    builtins.toJSON monitorOverride
  );

  # Caelestia writes runtime state back into shell.json itself (e.g. the VPN
  # tile saves utilities.vpn.enabled on every connect/disconnect, reformatting
  # the whole file as it goes), which would trip the liveReload watcher and
  # restart the shell mid-toggle. Only restart when the parsed settings
  # actually changed - ignoring formatting and the keys the shell owns.
  shellOwnedKeys = [ ".utilities.vpn.enabled" ];
  reloadCache = "\${XDG_RUNTIME_DIR:-/tmp}/caelestia-shell.json.normalized";
  normalizeShellJson = "${pkgs.jq}/bin/jq -S 'del(${lib.concatStringsSep ", " shellOwnedKeys})' \"${shellJsonPath}\"";
  reloadIfChanged = pkgs.writeShellScript "caelestia-reload-if-changed" ''
    cache="${reloadCache}"
    new=$(${normalizeShellJson}) || exit 0
    if [ -f "$cache" ] && [ "$new" = "$(cat "$cache")" ]; then
      exit 0
    fi
    printf '%s' "$new" > "$cache"
    exec ${pkgs.systemd}/bin/systemctl --user try-restart caelestia.service
  '';

  # The cache lives in XDG_RUNTIME_DIR, so it's gone after every login, and
  # the shell's first own write to shell.json (~1 min in) would restart it
  # unconditionally. Seeding it with what the shell is about to load avoids
  # that second startup.
  seedReloadCache = pkgs.writeShellScript "caelestia-seed-reload-cache" ''
    ${normalizeShellJson} > "${reloadCache}" || true
  '';

  # Apps whose notifications are only worth the popup: kitty (OSC 99 from
  # terminal programs, e.g. Claude Code's "waiting for input") and blueman
  # (every device connect/disconnect). Caelestia keeps every notification
  # until dismissed, so these piled up into the hundreds - and its animated
  # clear-all lags badly at that size. Patched below to close these outright
  # when their popup times out instead of just hiding the popup.
  ephemeralNotifApps = [
    "kitty"
    "blueman"
  ];

  # KillMode=process (below) leaves the shell's `nmcli monitor` children
  # running after every restart, orphaned in the unit's cgroup and each
  # still waking on every NetworkManager event. Kill just those.
  killLeftoverNmcli = pkgs.writeShellScript "caelestia-kill-leftover-nmcli" ''
    procs="/sys/fs/cgroup$(${pkgs.systemd}/bin/systemctl --user show -P ControlGroup caelestia.service)/cgroup.procs"
    [ -r "$procs" ] || exit 0
    while read -r pid; do
      [ "$(cat /proc/$pid/comm 2>/dev/null)" = nmcli ] && kill "$pid" 2>/dev/null
    done < "$procs"
    exit 0
  '';

  # Caelestia locks on logind's PrepareForSleep (general.idle.lockBeforeSleep)
  # but takes no delay inhibitor, so logind suspends before the lock surface
  # is drawn and the desktop flashes on wake (e.g. lid close). This holds one
  # on its behalf, released once the lock is secure (or logind's 5s
  # InhibitDelayMaxSec runs out), and retaken after resume.
  sleepLock = pkgs.writeShellScript "caelestia-sleep-lock" ''
    caelestia=${config.programs.caelestia.cli.package}/bin/caelestia
    pid=

    take() {
      ${pkgs.systemd}/bin/systemd-inhibit --what=sleep --mode=delay \
        --who="Caelestia" --why="Lock the screen before sleep" \
        ${pkgs.coreutils}/bin/sleep infinity &
      pid=$!
    }

    release() {
      [ -n "$pid" ] || return
      ${pkgs.procps}/bin/pkill -P "$pid" sleep
      wait "$pid"
      pid=
    }

    take
    while read -r line; do
      case "$line" in
        *"PrepareForSleep (true"*)
          for _ in $(${pkgs.coreutils}/bin/seq 40); do
            [ "$($caelestia shell lock isSecure 2>/dev/null)" = true ] && break
            ${pkgs.coreutils}/bin/sleep 0.1
          done
          # The first secure frame can still be mid fade-in.
          ${pkgs.coreutils}/bin/sleep 0.3
          release
          ;;
        *"PrepareForSleep (false"*)
          take
          ;;
      esac
    done < <(${pkgs.glib}/bin/gdbus monitor --system --dest org.freedesktop.login1 \
      --object-path /org/freedesktop/login1)
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

    liveReload = lib.mkEnableOption ''
      restarting the shell whenever shell.json changes. Caelestia's own
      watcher misses an editor's atomic rename-over-save on the repo file, so
      without this hand edits need `systemctl --user restart caelestia`.
      Off by default: it's only useful while actively editing, and each
      restart is a full shell startup
    '';

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
      home.activation.removeCaelestiaScheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
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

                # The brightness slider/IPC clamps to 0, which turns a laptop
                # backlight fully off. Floor internal panels at 1%; external
                # DDC/Apple displays still go to 0 (that just dims them).
                substituteInPlace services/Brightness.qml \
                  --replace-fail "value = Math.max(0, Math.min(1, value));" \
                                 "value = Math.max(isDdc || isAppleDisplay ? 0 : 0.01, Math.min(1, value));"

                # isLocked flips the instant locking is requested; `secure` only
                # once the compositor confirms the lock surface is up. Exposed
                # for caelestia-sleep-lock below.
                substituteInPlace modules/lock/Lock.qml \
                  --replace-fail "        function isLocked(): bool {" \
                                 "        function isSecure(): bool { return lock.secure; }
                function isLocked(): bool {"

                # See ephemeralNotifApps.
                substituteInPlace services/NotifData.qml \
                  --replace-fail "                notif.popup = false;" \
                                 "                notif.popup = false;
                        if (${builtins.toJSON ephemeralNotifApps}.includes(notif.appName))
                            notif.close();"
              '';
            });

        # settings/extraConfig deliberately left unset: setting either makes
        # home-manager own shell.json as a read-only store symlink (no live
        # editing, no writes from the GUI below). Instead, shell.json is
        # symlinked straight to this module's own file (out-of-store), so
        # editing it - by hand or via the GUI - lands directly in this
        # git-tracked file, no rebuild needed to pick it up (see liveReload).

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

      xdg.configFile."caelestia/shell.json".source = config.lib.file.mkOutOfStoreSymlink shellJsonPath;

      # Copied in as real files rather than xdg.configFile store symlinks:
      # Caelestia re-saves every per-monitor file whenever it writes runtime
      # state (e.g. the VPN tile), and a read-only store link makes each of
      # those saves fail with "Failed to save config". Rewritten on every
      # activation so the build-time content still wins; restarts the shell
      # only when it actually changed (its watcher misses the replace).
      home.activation.caelestiaMonitorOverrides = lib.mkIf (!cfg.showBattery) (
        lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          changed=0
          for monitor in ${lib.escapeShellArgs cfg.monitors}; do
            target="${config.xdg.configHome}/caelestia/monitors/$monitor/shell.json"
            if [ -L "$target" ] || ! cmp -s "${monitorOverrideFile}" "$target"; then
              run mkdir -p "$(dirname "$target")"
              run rm -f "$target"
              run install -m 644 "${monitorOverrideFile}" "$target"
              changed=1
            fi
          done
          if [ "$changed" = 1 ]; then
            run ${pkgs.systemd}/bin/systemctl --user try-restart caelestia.service || true
          fi
        ''
      );

      systemd.user = {
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
          # restart, including liveReload's. Only kill the shell.
          caelestia.Service = {
            KillMode = "process";
            ExecStartPre = lib.mkIf cfg.liveReload "${seedReloadCache}";
            ExecStopPost = "${killLeftoverNmcli}";
          };

          caelestia-sleep-lock = {
            Unit = {
              Description = "Delay sleep until Caelestia's lock screen is up";
              PartOf = [ "caelestia.service" ];
              After = [ "caelestia.service" ];
            };
            Service = {
              ExecStart = "${sleepLock}";
              Restart = "on-failure";
            };
            Install.WantedBy = [ "caelestia.service" ];
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
    (lib.mkIf (cfg.enable && cfg.liveReload) {
      # Watches the real repo file directly (not the ~/.config symlink, whose
      # watched inode dies with an editor's rename-over-save) - there's no IPC
      # reload command to use instead (checked caelestia-shell's source).
      systemd.user.paths.caelestia-config-reload = {
        Unit.Description = "Watch Caelestia's shell.json for changes";
        Path.PathModified = shellJsonPath;
        Install.WantedBy = [ "default.target" ];
      };

      systemd.user.services.caelestia-config-reload = {
        Unit.Description = "Restart Caelestia shell after shell.json changes";
        Service = {
          Type = "oneshot";
          ExecStart = "${reloadIfChanged}";
        };
      };
    })
  ];
}
