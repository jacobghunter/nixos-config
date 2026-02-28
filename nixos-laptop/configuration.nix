# ~/nixos-config/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ../nixos-shared/system.nix
    ../nixos-shared/graphical/configuration.nix
  ];

  # --- BOOT & HARDWARE ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "i915" ];

  # Hardware Acceleration (Video)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };

  # --- NETWORKING ---
  networking.hostName = "nixos-laptop";
  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;

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
}
