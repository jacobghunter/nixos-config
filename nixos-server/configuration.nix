{ config, pkgs, ... }:

{
  imports = [
    ../nixos-shared/system.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;

  # SSH for remote access
  services.openssh = {
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  # Allow sudo without password
  security.sudo.wheelNeedsPassword = false;

  # Allow members of the wheel group to be trusted by the Nix daemon
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  system.stateVersion = "25.05";
}
