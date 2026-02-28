{ config, pkgs, ... }:

{
  imports = [
    ../shared/home.nix
  ];

  home.packages = with pkgs; [
    kmod
  ];
}
