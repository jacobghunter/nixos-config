{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.modules.quickshell;
in
{
  options.modules.quickshell = {
    enable = lib.mkEnableOption "quickshell configuration";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.quickshell;
      description = "The quickshell package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Link local shell.qml and Bar.qml to ~/.config/quickshell/
    xdg.configFile."quickshell/shell.qml".source = ./shell.qml;
    xdg.configFile."quickshell/Bar.qml".source = ./Bar.qml;

    # User systemd service to run Quickshell
    systemd.user.services.quickshell = {
      Unit = {
        Description = "Quickshell Desktop Component Framework";
        After = [
          "graphical-session-pre.target"
          "pipewire.service"
          "pipewire-pulse.service"
          "wireplumber.service"
        ];
        PartOf = [ "graphical-session.target" ];
        Wants = [
          "pipewire.service"
          "pipewire-pulse.service"
          "wireplumber.service"
        ];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/quickshell";
        Restart = "on-failure";
        KillMode = "mixed";
        # Ensure Wayland env vars are present
        Environment = [
          "QT_QPA_PLATFORM=wayland"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
