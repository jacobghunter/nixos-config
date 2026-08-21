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
    text =
      builtins.replaceStrings
        [
          "STATIC_WALLPAPER=\"/nix/store/qi3biyjb3f8xw8rnjn03w8yqjik8cx9s-source/assets/backgrounds/outer-wilds.png\""
        ]
        [ "STATIC_WALLPAPER=\"${staticWallpaper}\"" ]
        (builtins.readFile ./scripts/power_monitor.sh);
    executable = true;
  };

  xdg.configFile."hypr/scripts/doom-eternal-wrapper.sh" = {
    source = ./scripts/doom-eternal-wrapper.sh;
    executable = true;
  };

  systemd.user.services.wallpaper-engine = {
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
