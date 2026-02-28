{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../nixos-shared/home.nix
  ];

  home.sessionVariables = {
    EDITOR = lib.mkForce "vim";
  };

  # --- SERVER SPECIFIC PACKAGES ---
  home.packages = with pkgs; [
  ];
}
