{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;

  # SSH for remote access
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  # Avahi for mDNS (allows accessing via nixos-server.local)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
      domain = true;
    };
  };

  # User Setup
  users.users.jacob = {
    isNormalUser = true;
    shell = pkgs.zsh;
    initialPassword = "password";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSF1X9Rhk/20YAwdqLI5zlZSIIZjL06/Rri8UZqv/Or jacob@nixos",
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFX1rPVicE6akrUGmXwuP5C2qmLtJ22E+Od1ZsU/on0H jacob@Jacobs-PC"
    ];
  };

  # Allow sudo without password
  security.sudo.wheelNeedsPassword = false;

  # Enable nix-ld for VS Code Remote SSH support
  programs.nix-ld.enable = true;

  # Allow members of the wheel group to be trusted by the Nix daemon
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  # Enable ZSH
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    nodejs
  ];

  system.stateVersion = "25.05";
}
