{ config, pkgs, ... }:

{
  # --- BOOT & HARDWARE ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.editor = false;

  # Set windows as default via sudo bootctl set-default auto-windows

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;

  # Pass audio codec model to the kernel for Realtek ALC897
  boot.kernelParams = [ "snd_hda_intel.model=auto" ];

  # Set windows to default boot via sudo bootctl set-default auto-windows

  time.hardwareClockInLocalTime = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "i915" ];

  # Hardware Acceleration (Video)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];
  };

  # --- NETWORKING ---
  networking.hostName = "nixos-pc";
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

  # --- AUDIO & SERVICES ---
  # Some already defined in graphical/configration.nix
  services.pipewire = {
    jack.enable = true; # It seems you had this enabled before, so I'm keeping it.
    wireplumber.enable = true;
    wireplumber.extraConfig = {
      main."50-subwoofer-fix" = ''
        alsa_monitor.rules = {
          {
            matches = {
              {
                -- Matches the Ryzen HD Audio Controller by its device name
                { "device.name", "equals", "alsa_card.pci-0000_10_00.6" }
              }
            },
            apply_properties = {
              ["audio.channels"] = 6,
              ["audio.position"] = "FL,FR,LFE,FC,SL,SR"
            }
          }
        }
      '';
    };
  };
}
