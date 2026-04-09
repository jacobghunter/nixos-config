{ config, pkgs, ... }:

{
  modules.kitty.enable = true;

  home.packages = with pkgs; [
    kmod
  ];
}
