{
  pkgs,
  inputs,
  ...
}:

{
  time.timeZone = "America/Phoenix";

  nixpkgs = {
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];

    # Allow unfree packages (like VS Code)
    config.allowUnfree = true;
    config.permittedInsecurePackages = [
      "electron-39.8.10"
    ];
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };

    openssh.enable = true;
    upower.enable = true;
  };

  programs = {
    zsh.enable = true;

    ## Enable nix-ld for better compatibility with unpatched binaries (helpful for VS Code remote)
    nix-ld.enable = true;
  };

  users.users.jacob = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Jacob Hunter";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSF1X9Rhk/20YAwdqLI5zlZSIIZjL06/Rri8UZqv/Or jacob@nixos-laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFX1rPVicE6akrUGmXwuP5C2qmLtJ22E+Od1ZsU/on0H jacob@Jacobs-PC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0WYLgYAAWBISrS7w+QTxPohk4xb8kHbBQIwlJWMCiY jacob@nixos-wsl"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENlOaDve6NsoV4BfHjM0xbNnfwPOZzm4FQ+up6eHz9d jacob@nixos-pc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINTbg6xTr+WRsLqKQsRZveSIk+PWsp1gYYSVxKA2mW+I jacob@nixos-server"
    ];
  };

  # Common System Packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
    gping
    hyperfine
    curlie
    ffmpeg-headless
    uv
    proton-vpn-cli
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    material-symbols
    inter
  ];

  # None of our hosts root on ZFS, so force-importing on boot is unnecessary
  # and risks silently importing a pool in an inconsistent state.
  boot.zfs.forceImportRoot = false;

  nix = {
    # Enable Nix Flakes
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      download-buffer-size = 134217728;
      trusted-users = [
        "root"
        "@wheel"
      ];

      # Local attic cache on the server (nixos-server/modules/attic) - public
      # read, LAN-only, so any host here can pull already-built outputs (e.g.
      # a kernel built for the pi) instead of rebuilding them.
      substituters = [ "http://192.168.1.167:8081/nixos-config" ];
      trusted-public-keys = [ "nixos-config:8W0E2b09uOT6kNIBlkeEgfHnVG5jiD/nm5oG586Vi1o=" ];
      # Away from home without Tailscale (or with the home internet down) the
      # cache above is unreachable. It answers in milliseconds when it's up,
      # so give up quickly instead of 15s x 5 attempts per path, and build
      # locally when a substitute can't be fetched rather than failing.
      connect-timeout = 3;
      fallback = true;

      # Safety net between weekly GCs: if free space drops under 10 GiB during
      # a build, nix collects garbage until 30 GiB is free (or nothing's left).
      min-free = 10 * 1024 * 1024 * 1024;
      max-free = 30 * 1024 * 1024 * 1024;
    };

    # Without this, every rebuild's old generation and everything only it
    # used stays in the store forever (the laptop hit 113 GiB of it). Generations
    # older than 14 days go, and with them their boot menu entries. Persistent
    # timer, so a run missed while the machine was off/asleep happens on boot.
    # Both jobs are disk-heavy, so they run early Monday morning rather than
    # midnight (gc's "weekly") or nightly (optimise's default) - off gaming hours.
    gc = {
      automatic = true;
      dates = "Mon 04:00";
      options = "--delete-older-than 14d";
    };

    # Hard-links identical files across store paths.
    optimise = {
      automatic = true;
      dates = [ "Mon 04:30" ];
    };
  };
}
