{ config, pkgs, ... }:

{
  imports = [
    ../shared/home.nix
  ];

  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  
  # Server state version
  home.stateVersion = "24.11"; 

  # --- SERVER SPECIFIC PACKAGES ---
  home.packages = with pkgs; [
    # Add server-only packages here if needed
    vim
    htop
  ];
  
  programs.home-manager.enable = true;
}
