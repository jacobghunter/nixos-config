{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.modules.dankMaterialShell;
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
    };
  };
}
