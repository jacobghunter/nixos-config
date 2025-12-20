# ~/nixos-config/configuration.nix
{ config, pkgs, ... }:

{
  # --- BOOT & HARDWARE ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hardware Acceleration (Video)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };

  # QMK Keyboard Support (Needs root for udev rules)
  hardware.keyboard.qmk.enable = true;

  # Bluetooth (System Service)
  hardware.bluetooth.settings.General.ControllerMode = "bredr";

  # --- NETWORKING ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Firewall & DNS
  networking.nameservers = [
    "94.140.14.14"
    "1.1.1.1"
  ];
  services.openssh.enable = true;

  # Weylus / Streaming Ports (Must be system-level firewall)
  programs.weylus = {
    enable = true;
    openFirewall = true;
    users = [ "jacob" ];
  };
  networking.firewall.allowedTCPPorts = [
    7236
    7250
  ];
  networking.firewall.allowedUDPPorts = [
    7236
    5353
  ];

  # --- LOCALIZATION ---
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # --- AUDIO & SERVICES ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = true; # CUPS
  virtualisation.docker.enable = true;

  # --- USERS ---
  users.users.jacob = {
    isNormalUser = true;
    description = "Jacob Hunter";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    # Note: We removed 'packages = ...' here. We use home.nix for that now.
  };

  # --- SYSTEM MAINTENANCE ---
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "daily";
    flags = [ "--upgrade" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.05";

  # --- SYSTEM PACKAGES ---
  # Only tools needed by "root" or for system rescue
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    usbutils
    util-linux
    nixfmt-rfc-style
  ];
}
