{ config, pkgs, ... }:

{
  imports = [
    ../shared/home.nix
  ];

  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "24.11";

  # WSL-specific overrides can go here
  
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    mkmod
  ]
}
