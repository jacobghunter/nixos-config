{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl.enable = true;
  wsl.defaultUser = "jacob";

  networking.hostName = "nixos-wsl";

  # Enable nix-command and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
  ];

  system.stateVersion = "24.11";
}
