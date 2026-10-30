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
