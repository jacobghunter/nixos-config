{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.sessionVariables = {
    EDITOR = lib.mkForce "vim";
  };

  # --- SERVER SPECIFIC PACKAGES ---
  home.packages = with pkgs; [
  ];
}
