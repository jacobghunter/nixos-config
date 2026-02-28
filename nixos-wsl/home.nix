{ config, pkgs, ... }:

{
  imports = [
    ../nixos-shared/home.nix
  ];

  home.packages = with pkgs; [
    kmod
  ];
}
