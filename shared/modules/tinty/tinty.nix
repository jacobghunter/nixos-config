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

    xdg.configFile = {
      "tinted-theming/tinty/config.toml".text = ''
        ${builtins.readFile tintyToml}

        [[items]]
        name = "quickshell-colors"
        # We re-use tinted-shell's path so tinty finds valid templates and doesn't crash.
        # NOTE: nixpkgs' tinty (0.32.2) always does a git-based `update` on every
        # configured item regardless of path type - a local nix store path breaks
        # on the second sync (no local-path exemption until upstream's unreleased
        # main branch). Keep this as a real git URL; the activation script below
        # tolerates the resulting network failure instead.
        path = "https://github.com/tinted-theming/tinted-shell"
        themes-dir = "scripts"
        supported-systems = ["base16", "base24"]
        hook = "${hookPath}"
      '';

      "tinted-theming/tinty/hooks/quickshell-colors.sh" = {
        source = ./quickshell-colors.sh;
        executable = true;
      };

      "quickshell/lib/Theme.qml".source = ./Theme.qml;

      "quickshell/lib/qmldir".text = ''
        module qs.lib
        singleton Colors 1.0 Colors.qml
        singleton Theme 1.0 Theme.qml
      '';
    };

    programs.zsh.initContent = ''
      [ -f ~/.cache/tinted-fzf-theme.sh ] && source ~/.cache/tinted-fzf-theme.sh
    '';

    home.activation.tintyApply = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${pkgs.git}/bin:$PATH"
      # tinty sync needs network (git fetch for the tinted-shell template) and
      # must never fail the rest of home-manager activation just because we're
      # offline or booting before the network is up - keep last-synced templates.
      $DRY_RUN_CMD ${pkgs.tinty}/bin/tinty sync || echo "tinty sync failed (offline?), using existing templates"
      $DRY_RUN_CMD ${pkgs.tinty}/bin/tinty init
    '';
  };
}
