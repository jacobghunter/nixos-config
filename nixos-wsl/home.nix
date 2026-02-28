{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    kmod
  ];
}
