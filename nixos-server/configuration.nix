{ pkgs, ... }:

{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # QEMU emulation for cross-building aarch64
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;

  services = {
    # SSH for remote access
    openssh.settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };

    # For local llms
    ollama.enable = true;

    qbittorrent = {
      enable = true;
      openFirewall = true;
      webuiPort = 8082;
    };
  };
  # Allow sudo without password
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  system.stateVersion = "25.05";
}
