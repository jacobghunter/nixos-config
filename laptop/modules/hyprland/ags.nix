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
    configDir = ./ags;

    # Extra packages available to GJS
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk_4_1
      accountsservice
      dart-sass
      inputs.astal.packages.${pkgs.system}.battery
      inputs.astal.packages.${pkgs.system}.hyprland
      inputs.astal.packages.${pkgs.system}.wireplumber
      inputs.astal.packages.${pkgs.system}.network
      inputs.astal.packages.${pkgs.system}.tray
      inputs.astal.packages.${pkgs.system}.io
    ];
  };
}
