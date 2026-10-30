{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.noctalia;
  fromTOMLFile = path: builtins.fromTOML (builtins.readFile path);
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.modules.noctalia = {
    enable = lib.mkEnableOption "noctalia";
    hostConfig = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Host-specific TOML (monitors, widget placement, plugins) merged over config.toml.";
    };
  };

  config = lib.mkIf cfg.enable {
    # `noctalia panel-toggle <id>` is Noctalia's own IPC CLI (src/ipc/ipc_service.h);
    # "launcher" is the built-in panel id for its app launcher.
    modules.activeShellLauncherCmd = "noctalia panel-toggle launcher";

    # Needed by the special-workspaces plugin to listen to Hyprland's event socket
    home.packages = [ pkgs.socat ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      # Exported from the GUI with `noctalia config export`
      settings = lib.recursiveUpdate (fromTOMLFile ./config.toml) (
        lib.optionalAttrs (cfg.hostConfig != null) (fromTOMLFile cfg.hostConfig)
      );
    };
  };
}
