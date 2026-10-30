{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.modules.caelestia;
  # Started from a full community shell.json instead of the (very sparse)
  # upstream defaults. Original source: acastaneiras/caelestia
  # (https://github.com/acastaneiras/caelestia/blob/main/shell.json), since
  # hand-edited directly in this repo file - see git log for what changed.
  shellJsonPath = "${config.home.homeDirectory}/nixos-config/shared/graphical/modules/caelestia/shell.json";
in
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  options.modules.caelestia = {
    enable = lib.mkEnableOption "the Caelestia desktop shell";
  };

  config = lib.mkIf cfg.enable {
    # `caelestia shell <message...>` sends an IPC message to the running
    # shell (see daemons/Shortcuts.qml's `drawers` IpcHandler) - this is the
    # same mechanism the CLI's own launcher actions use, just invoked directly
    # so the shared Hyprland config doesn't need to know Caelestia's IPC shape.
    modules.activeShellLauncherCmd = "caelestia shell drawers toggle launcher";

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

    xdg.configFile = {
      "caelestia/shell.json".source = config.lib.file.mkOutOfStoreSymlink shellJsonPath;
    };

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

    systemd.user.services.caelestia-config-reload = {
      Unit.Description = "Restart Caelestia shell after shell.json changes";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl --user try-restart caelestia.service";
      };
    };
  };
}
