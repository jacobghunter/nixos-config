{ pkgs, lib, ... }:

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

    # QEMU emulation for cross-building aarch64 (the Pis)
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  time.hardwareClockInLocalTime = true;

  services = {
    xserver.videoDrivers = [ "amdgpu" ];

    # Wake-on-LAN (magic packet) on the onboard r8169 NIC, so the server can wake
    # the PC from suspend - see `wake-pc` in nixos-server/configuration.nix.
    # Done with ethtool from udev rather than networking.interfaces.eno1.wakeOnLan:
    # that option's .link file matches OriginalName (the kernel's eth0, not the
    # renamed eno1), so it never applies. Matching on MAC survives renames.
    # NetworkManager leaves WoL alone (its per-connection default is "ignore").
    # Also needs "Wake on LAN" / "Power On By PCI-E" enabled in the BIOS.
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="cc:28:aa:46:2e:ad", RUN+="${pkgs.ethtool}/bin/ethtool -s $name wol g"
    '';

    # --- AUDIO ---
    # Some already defined in graphical/configration.nix
    pipewire = {
      jack.enable = true;
      wireplumber.enable = true;
    };
  };

  # Hardware Acceleration (Video)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for 32-bit game libraries and Steam Overlay
    extraPackages = with pkgs; [ libva-vdpau-driver ];
  };

  networking = {
    hostName = "nixos-pc";
    # Pi-hole full time. The router's DHCP also advertises itself (192.168.1.1)
    # as a DNS server, and resolved drifts onto it whenever Pi-hole misses a
    # reply - then local records (server.home, go) stop resolving. So NM keeps
    # its DHCP DNS to itself and resolved only knows about the Pi-holes: the Pi,
    # then the backup on nixos-server (same records, so failover is harmless).
    # The PC never leaves the LAN; the laptop keeps the shared AdGuard/Cloudflare set.
    networkmanager = {
      enable = true;
      # Overrides resolved.nix's "systemd-resolved"; tailscaled still talks to
      # resolved directly, so split DNS is unaffected.
      dns = lib.mkForce "none";
    };
    nameservers = lib.mkForce [
      "192.168.1.14"
      "192.168.1.167"
    ];
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
}
