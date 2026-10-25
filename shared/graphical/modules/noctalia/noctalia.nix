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
