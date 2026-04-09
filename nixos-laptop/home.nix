{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    powerstat
    upower
    screen
  ];
}
