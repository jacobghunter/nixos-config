{ pkgs, ... }:

{
  imports = [
    ./gaming.nix
    ./modules/macros
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        xbootldrMountPoint = "/boot";
      };

      grub.enable = false;

      efi.efiSysMountPoint = "/efi";
      # Set windows as default via sudo bootctl set-default auto-windows

      efi.canTouchEfiVariables = true;
      timeout = 10;
    };

    # Pass audio codec model to the kernel for Realtek ALC897
    kernelParams = [
      "snd_hda_intel.model=auto"
    ];
  };

  time.hardwareClockInLocalTime = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  # Hardware Acceleration (Video)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for 32-bit game libraries and Steam Overlay
    extraPackages = with pkgs; [ libva-vdpau-driver ];
  };

  networking = {
    hostName = "nixos-pc";
    networkmanager.enable = true;
    enableIPv6 = false;

    firewall.allowedTCPPorts = [
      7236
      7250
    ];
  };

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

  # --- SYSTEM MAINTENANCE ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # --- AUDIO & SERVICES ---
  # Some already defined in graphical/configration.nix
  services.pipewire = {
    jack.enable = true;
    wireplumber.enable = true;
  };
}
