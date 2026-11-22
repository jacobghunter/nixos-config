_:

{
  imports = [ ./klipper.nix ];

  networking = {
    hostName = "nixos-printer";
  };

  # nixos-hardware's raspberry-pi-3 module needs generic-extlinux-compatible
  # (u-boot chainloading extlinux.conf), but their newer firmware.nix module
  # only stages u-boot.bin onto the sd-image when this is explicitly enabled
  # - it defaults to off, which silently produces an unbootable firmware
  # partition (no u-boot.bin, no `kernel=` line in config.txt).
  hardware.raspberry-pi.firmware.uboot.enable = true;

  sdImage.expandOnBoot = true;

  # Headless printer box: no display, no bluetooth. This Pi 3B froze ~15s into
  # every NixOS boot until these drivers were kept from loading (graphics
  # handover was the last thing seen on screen). Kernel-param form, not
  # boot.blacklistedKernelModules, to match exactly what was tested.
  boot.kernelParams = [ "module_blacklist=vc4,hci_uart,btbcm" ];

  # avahi (for `ssh jacob@nixos-printer.local`), users.users.jacob + its
  # authorized keys, services.openssh.enable, and nix.settings.trusted-users
  # all come from shared/configuration.nix.
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };

  # No sudo password — local network only, quick bootstrap.
  security.sudo.wheelNeedsPassword = false;

  # sd-image-aarch64.nix ships a root user with an empty password by
  # default; lock it down since this box is reachable over wifi.
  users.users.root.hashedPassword = "!";

  system.stateVersion = "26.11";
}
