{ config, pkgs, ... }:

{
  imports = [
    ../nixos-shared/home.nix
    ../nixos-shared/graphical/home.nix
  ];

  home.packages = with pkgs; [
    powerstat
    upower
    screen
  ];
}
