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
  };
  # Allow sudo without password
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  modules.makemkv = {
    enable = true;
    # sg0 is the WD disk (target 3:0:0:0); the BD-RE drive (target
    # 10:0:0:0) is sg1 - confirmed via udevadm/lsscsi, not the module's
    # default guess. Both /dev/sr0 and /dev/sg1 are group cdrom (gid 24).
    devices = [
      "/dev/sr0"
      "/dev/sg1"
    ];
    extraEnvironment.SUP_GROUP_IDS = "24";
  };

  system.stateVersion = "25.05";
}
