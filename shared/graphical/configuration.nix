{ config, pkgs, ... }:

{
  imports = [
    ../system.nix
  ];
  # QMK Keyboard Support (Needs root for udev rules)
  hardware.keyboard.qmk.enable = true;

  # Bluetooth (System Service)
  hardware.bluetooth.enable = true; # <--- Enable the daemon
  hardware.bluetooth.powerOnBoot = false;
  hardware.bluetooth.settings.General.ControllerMode = "dual";
  services.blueman.enable = true;

  # Firewall & DNS
  networking.nameservers = [
    "94.140.14.14"
    "1.1.1.1"
  ];

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
    texlive.combined.scheme-full # Latex engine
  ];
}
