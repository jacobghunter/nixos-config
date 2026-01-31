# ~/nixos-config/configuration.nix
{ config, pkgs, ... }:

{
  # --- BOOT & HARDWARE ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "i915" ];

  # Hardware Acceleration (Video)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };

  # QMK Keyboard Support (Needs root for udev rules)
  hardware.keyboard.qmk.enable = true;

  # Bluetooth (System Service)
  hardware.bluetooth.enable = true; # <--- Enable the daemon
  hardware.bluetooth.powerOnBoot = false;
  hardware.bluetooth.settings.General.ControllerMode = "dual";
  services.blueman.enable = true;

  # --- NETWORKING ---
  networking.hostName = "nixos-laptop";
  networking.networkmanager.enable = true;

  # Firewall & DNS
  networking.nameservers = [
    "94.140.14.14"
    "1.1.1.1"
  ];
  services.openssh.enable = true;
  services.vscode-server.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Weylus / Streaming Ports (Must be system-level firewall)
  programs.weylus = {
    enable = true;
    openFirewall = true;
    users = [ "jacob" ];
  };
  networking.firewall.allowedTCPPorts = [
    7236
    7250
    9090 # Calibre Wireless Connection
    8080 # Calibre Content Server
  ];
  networking.firewall.allowedUDPPorts = [
    7236
  ];

  # --- POWER MANAGEMENT ---
  services.power-profiles-daemon.enable = false; # Disable GNOME power profiles to use TLP
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Fix slow internet
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";

      # Optional: Charge thresholds for ThinkPad longevity (starts charging at 75%, stops at 80%)
      # START_CHARGE_THRESH_BAT0 = 75;
      # STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # --- LOCALIZATION ---
  time.timeZone = "America/Phoenix";
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

  # General Services
  services.xserver.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.udev.packages = [ pkgs.calibre ];
  services.gnome.gnome-keyring.enable = true;

  services.printing.enable = true; # CUPS
  virtualisation.docker.enable = true;

  programs.dconf.enable = true;

  # --- USERS ---
  users.users.jacob = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Jacob Hunter";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
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
    dates = "weekly";
    flags = [ "--upgrade" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "25.05";

  fonts.fontconfig.enable = true;

  # --- SYSTEM PACKAGES ---
  # Only tools needed by "root" or for system rescue
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    btop
    tree
    usbutils
    util-linux
    nixfmt-rfc-style
    seahorse # GUI for gnome-keyring
  ];
}
