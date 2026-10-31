{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.modules.dankMaterialShell;
  # Mirrors caelestia.nix's approach: dumped from the live ~/.config/dms/settings.json
  # (DMS writes this back constantly as its own app state - window/plugin/theme
  # settings, not just static config), then tracked here and symlinked back
  # out-of-store so hand edits or DMS's own Settings UI keep landing in this
  # git-tracked file instead of a read-only nix-store copy.
  settingsPath = "${config.home.homeDirectory}/nixos-config/shared/graphical/modules/dank-material-shell/settings.json";
in
{
  imports = [
    inputs.dank-material-shell.homeModules.dank-material-shell
  ];

  options.modules.dankMaterialShell = {
    enable = lib.mkEnableOption "the Dank Material Shell desktop shell";
  };

  config = lib.mkIf cfg.enable {
    # `dms ipc call <target> <function>` is Dank/Dux's own IPC CLI;
    # "spotlight"/"launcher" are synonymous targets for its app launcher.
    modules.activeShellLauncherCmd = "dms ipc call spotlight toggle";

    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
      # By default this module rebuilds dms-shell against *our* nixpkgs, which
      # lags the go version its go.mod requires. Use the flake's own prebuilt
      # package (built against its own pinned nixpkgs) instead.
      package = inputs.dank-material-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;

      # settings deliberately left unset: it writes a nix-store-owned
      # read-only settings.json, which fights with DMS constantly rewriting
      # its own state there. The out-of-store symlink below does the same job
      # shell.json's symlink does for Caelestia.
    };

    xdg.configFile."dms/settings.json".source = config.lib.file.mkOutOfStoreSymlink settingsPath;

    # Same tray items excluded for Caelestia (bar.tray.hiddenIcons) - DMS reads
    # this as a comma-separated, case-insensitive env var (TrayMenuManager.qml)
    # rather than a settings.json field. Set directly on the unit (not
    # home.sessionVariables) so home-manager restarts dms.service on change -
    # a plain session variable wouldn't reach an already-running process.
    systemd.user.services.dms.Service.Environment = [
      "DMS_HIDE_TRAYIDS=nm-applet,blueman,easyeffects"
    ];
  };
}
