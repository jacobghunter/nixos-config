{ pkgs, ... }:

{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # QEMU emulation for cross-building aarch64
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;

  services = {
    # SSH for remote access
    openssh.settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };

    # For local llms
    ollama.enable = true;

    qbittorrent = {
      enable = true;
      openFirewall = true;
      webuiPort = 8082;
    };

    # Firmware updates (Dell OptiPlex 3060, on BIOS 1.13.0 from 2021 as of
    # Nov 2026). Only refreshes the list of available updates - never installs
    # on its own. `fwupdmgr get-updates` to check.
    # TODO: update the BIOS while physically home - `sudo fwupdmgr update`,
    # then re-check in the BIOS: AC Recovery = Power On, Continue on Warnings
    # and Errors, Deep Sleep off / Wake on LAN = LAN Only, and that it still
    # boots "Linux Boot Manager". A BIOS update can reset any of those.
    fwupd.enable = true;
  };
  # Allow sudo without password
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    nodejs
    # Wake the PC from suspend with a magic packet. Run here rather than from a
    # roaming device: WoL is a LAN broadcast, which doesn't cross Tailscale's
    # subnet route - so from away, `ssh` in and run it (laptop: `wake-pc` alias).
    (writeShellScriptBin "wake-pc" ''
      ${wakeonlan}/bin/wakeonlan -i 192.168.1.255 cc:28:aa:46:2e:ad
    '')
    # The laptop's Wi-Fi and ethernet - only reaches it while it's on the home
    # LAN (a sleeping laptop elsewhere isn't on this network or the tailnet).
    (writeShellScriptBin "wake-laptop" ''
      ${wakeonlan}/bin/wakeonlan -i 192.168.1.255 a0:29:42:c8:3c:e1 9c:2d:cd:fc:ba:8a
    '')
  ];

  modules = {
    caddy = {
      enable = true;
      # Flip on once DNS + CF_API_TOKEN env file are ready to expose Jellyfin
      # publicly; leave off for LAN-only (homepage catch-all + go-links).
      cloudflareEnvironmentFile = "/etc/cloudflare.env";
      publicJellyfin.enable = true;
      # Kobo Sync only (/kobo/*) - the Calibre-Web UI stays LAN/Tailscale-only.
      publicCalibreKobo.enable = true;
    };

    # Backup Pi-hole, so DNS survives nixos-pihole going down. Same records,
    # password and blocklists as the Pi (shared module defaults). Web UI moves
    # off 80, which caddy owns: http://server.home:8053/admin
    pihole = {
      enable = true;
      interface = "enp1s0";
      webPort = 8053;
    };

    # Remote access to the home network. After the first deploy, run
    # `sudo tailscale up` once, then approve the subnet route + exit node in
    # the Tailscale admin console (and disable key expiry for this machine).
    tailscale = {
      enable = true;
      advertiseRoutes = [ "192.168.1.0/24" ];
      exitNode = true;
    };

    makemkv = {
      enable = true;
      # /dev/sgN numbering shifts whenever USB devices are replugged/moved, so
      # pass the Blu-ray drive via the stable udev symlinks below. Both are
      # group cdrom (gid 24).
      devices = [
        "/dev/bluray:/dev/sr0"
        "/dev/bluray-sg:/dev/sg0"
      ];
      extraEnvironment.SUP_GROUP_IDS = "24";
      outputDir = "/media/storage/movies";
      # Match jellyfin's GID
      pgid = 990;
    };
  };

  # Stable names for the USB Blu-ray drive (see makemkv above).
  services.udev.extraRules = ''
    SUBSYSTEM=="block", KERNEL=="sr*", ATTRS{vendor}=="HL-DT-ST", ATTRS{model}=="BD-RE BP60NB10*", SYMLINK+="bluray"
    SUBSYSTEM=="scsi_generic", ATTRS{vendor}=="HL-DT-ST", ATTRS{model}=="BD-RE BP60NB10*", SYMLINK+="bluray-sg"
  '';

  system.stateVersion = "25.05";
}
