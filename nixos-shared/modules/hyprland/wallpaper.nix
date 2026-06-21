{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.modules.hyprland;
  staticWallpaper = "${inputs.self}/assets/backgrounds/outer-wilds.png";
  # videoWallpaper = "${inputs.self}/assets/backgrounds/outer-wilds.mp4";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "wpe-list" (builtins.readFile ./scripts/wpe-list.sh))
    (pkgs.writeShellScriptBin "wpe-apply" (builtins.readFile ./scripts/wpe-apply.sh))
  ];

  xdg.configFile."hypr/scripts/power_monitor.sh" = {
    source = ./scripts/power_monitor.sh;
    executable = true;
  };

  xdg.configFile."hypr/scripts/doom-eternal-wrapper.sh" = {
    source = ./scripts/doom-eternal-wrapper.sh;
    executable = true;
  };

  systemd.user.services.power-monitor = {
    Unit = {
      Description = "Power Monitor Wallpaper Service";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${config.xdg.configHome}/hypr/scripts/power_monitor.sh";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
