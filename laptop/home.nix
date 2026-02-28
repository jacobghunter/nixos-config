{ config, pkgs, ... }:

{
  imports = [
    ../shared/home.nix
    ../shared/graphical/home.nix
  ];

  home.packages = with pkgs; [
    powerstat
    upower
    screen
  ];
}
