{ config, pkgs, ... }:

{
  imports = [
    ./gaming.nix
  ];

  # --- BOOT & HARDWARE ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.editor = false;

  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";
  boot.loader.efi.efiSysMountPoint = "/efi";
  # Set windows as default via sudo bootctl set-default auto-windows

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;

  # Pass audio codec model to the kernel for Realtek ALC897
  boot.kernelParams = [
    "snd_hda_intel.model=auto"
  ];

  time.hardwareClockInLocalTime = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  # Hardware Acceleration (Video)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for 32-bit game libraries and Steam Overlay
    extraPackages = with pkgs; [ libva-vdpau-driver ];
  };

  # --- NETWORKING ---
  networking.hostName = "nixos-pc";
  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs =
        pkgs: with pkgs; [
          gamescope
        ];
    };
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

  # --- SYSTEM MAINTENANCE ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  boot.loader.systemd-boot.configurationLimit = 5;

  # --- AUDIO & SERVICES ---
  # Some already defined in graphical/configration.nix
  services.pipewire = {
    jack.enable = true;
    wireplumber.enable = true;
  };
}
