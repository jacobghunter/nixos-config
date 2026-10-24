{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.noctalia;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.modules.noctalia = {
    enable = lib.mkEnableOption "noctalia";
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings = {
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };

        # wallpaper = {
        #   enabled = true;
        #   default.path = "/path/to/wallpapers/wallpaper.png";
        # };
      };
    };
  };
}
