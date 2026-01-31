{ config, pkgs, ... }:

{
  imports = [
    ../shared/system.nix
  ];

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

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    nodejs
  ];

  system.stateVersion = "25.05";
}
