{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.tinty;
  
  tintyToml = ./tinty.toml;
  hookPath = "${config.xdg.configHome}/tinted-theming/tinty/hooks/quickshell-colors.sh";
in
{
  options.modules.tinty = {
    enable = lib.mkEnableOption "tinty theming";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      tinty
    ];

    xdg.configFile."tinted-theming/tinty/config.toml".text = ''
      ${builtins.readFile tintyToml}
      
      [[items]]
      name = "quickshell-colors"
      # We re-use tinted-shell's path so tinty finds valid templates and doesn't crash
      path = "https://github.com/tinted-theming/tinted-shell"
      themes-dir = "scripts"
      supported-systems = ["base16", "base24"]
      hook = "${hookPath}"
    '';

    xdg.configFile."tinted-theming/tinty/hooks/quickshell-colors.sh" = {
      source = ./quickshell-colors.sh;
      executable = true;
    };

    xdg.configFile."quickshell/lib/Theme.qml".source = ./Theme.qml;

    xdg.configFile."quickshell/lib/qmldir".text = ''
      module qs.lib
      singleton Colors 1.0 Colors.qml
      singleton Theme 1.0 Theme.qml
    '';

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
