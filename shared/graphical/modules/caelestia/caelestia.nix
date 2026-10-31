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

  config = lib.mkIf cfg.enable {
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

    programs.caelestia = {
      enable = true;
      systemd.enable = true;

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
    systemd.user.paths.caelestia-config-reload = {
      Unit.Description = "Watch Caelestia's shell.json for changes";
      Path.PathModified = shellJsonPath;
      Install.WantedBy = [ "default.target" ];
    };

    # The launcher spawns apps as plain children (DesktopEntry.execute), so
    # they land in caelestia.service's cgroup - and the default
    # KillMode=control-group takes Steam/Discord/etc. down with every shell
    # restart, including the config-reload one below. Only kill the shell.
    systemd.user.services.caelestia.Service.KillMode = "process";

    systemd.user.services.caelestia-config-reload = {
      Unit.Description = "Restart Caelestia shell after shell.json changes";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl --user try-restart caelestia.service";
      };
    };
  };
}
