{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    "${inputs.self}/nixos-shared/configuration.nix"
    ./modules/calibre/configuration.nix
  ];

  hardware = {
    # QMK Keyboard Support (Needs root for udev rules)
    keyboard.qmk.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      package = pkgs.bluez;
      settings = {
        General = {
          ControllerMode = "dual";
          Experimental = true;
          KernelExperimental = true;
          FastConnectable = false;
          Privacy = "off";
          JustWorksRepairing = "always";
        };
      };
    };
  };

  systemd.services.bluetooth.serviceConfig.ExecStart = [
    ""
    "${pkgs.bluez}/libexec/bluetooth/bluetoothd -E -f /etc/bluetooth/main.conf"
  ];

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    xserver.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    gnome = {
      gnome-keyring.enable = true;
      evolution-data-server.enable = true;
      gnome-online-accounts.enable = true;
    };
    printing.enable = true; # CUPS

    blueman.enable = true;
  };

  # Firewall & DNS
  networking.nameservers = [
    "94.140.14.14"
    "1.1.1.1"
  ];

  # --- LOCALIZATION ---
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

  system.stateVersion = "25.05";

  fonts.fontconfig.enable = true;

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # --- SYSTEM PACKAGES ---
  # Only tools needed by "root" or for system rescue
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    htop
    tree
    usbutils
    util-linux
    nixfmt
    nixfmt-tree
    deadnix
    statix
    seahorse # GUI for gnome-keyring
    texlive.combined.scheme-full # Latex engine
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    proton-vpn
  ];
}
