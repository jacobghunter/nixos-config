{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.tinty;
in
{
  options.modules.tinty = {
    enable = lib.mkEnableOption "tinty theming";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      tinty
    ];
    xdg.configFile."tinted-theming/tinty/config.toml".text = builtins.readFile ./tinty.toml;

    xdg.configFile."tinted-theming/tinty/hooks/quickshell-colors.sh" = {
      source = ./quickshell-colors.sh;
      executable = true;
    };

    programs.zsh.initContent = ''
      [ -f ~/.cache/tinted-fzf-theme.sh ] && source ~/.cache/tinted-fzf-theme.sh
    '';

    home.activation.tintyApply = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${pkgs.git}/bin:$PATH"
      $DRY_RUN_CMD ${pkgs.tinty}/bin/tinty sync
      $DRY_RUN_CMD ${pkgs.tinty}/bin/tinty init
    '';
  };
}
