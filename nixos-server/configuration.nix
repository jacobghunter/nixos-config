{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # QEMU emulation for cross-building aarch64
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  # For local llms
  services.ollama.enable = true;

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = 8082;
  };

  system.stateVersion = "25.05";
}
