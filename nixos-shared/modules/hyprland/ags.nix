{
  pkgs,
  config,
  inputs,
  ...
}:

{
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;

    # Symlink to ~/.config/ags
    configDir = "${inputs.self}/nixos-shared/modules/hyprland/ags";

    # Extra packages available to GJS
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk_4_1
      accountsservice
      dart-sass
      inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.battery
      inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
      inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.wireplumber
      inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.network
      inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.tray
      inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.io
    ];
  };
}
