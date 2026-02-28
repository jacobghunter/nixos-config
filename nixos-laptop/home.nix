{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    powerstat
    upower
    screen
  ];
}
