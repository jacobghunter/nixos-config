_:

{
  networking = {
    hostName = "nixos-parents";
  };

  # nixos-hardware's raspberry-pi-3 module needs generic-extlinux-compatible
  # (u-boot chainloading extlinux.conf), but their newer firmware.nix module
  # only stages u-boot.bin onto the sd-image when this is explicitly enabled
  # - it defaults to off, which silently produces an unbootable firmware
  # partition (no u-boot.bin, no `kernel=` line in config.txt).
  hardware.raspberry-pi.firmware.uboot.enable = true;

  # sd-image's first-boot expand-root-partition (sfdisk + partprobe +
  # resize2fs on the live root disk) froze this Pi 3 solid every time, on
  # two different cards - last journal line was always that unit starting.
  # Grow the partition offline on the PC after flashing instead:
  #   nix shell nixpkgs#cloud-utils nixpkgs#e2fsprogs -c sh -c \
  #     'sudo growpart /dev/sdX 2 && sudo e2fsck -f /dev/sdX2 && sudo resize2fs /dev/sdX2'
  sdImage.expandOnBoot = false;

  # avahi (for `ssh jacob@nixos-parents.local`), users.users.jacob + its
  # authorized keys, services.openssh.enable, and nix.settings.trusted-users
  # all now come from shared/configuration.nix instead of being duplicated
  # here - that duplication is exactly what let the pi's authorized keys
  # drift out of sync with the shared list.
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };

  # Exit node on the parents' network. After the first deploy, run
  # `sudo tailscale up --advertise-exit-node` once, then approve the exit
  # node in the Tailscale admin console (and disable key expiry for this
  # machine). No subnet route: home already advertises 192.168.1.0/24.
  modules.tailscale = {
    enable = true;
    exitNode = true;
  };

  # No sudo password — local network only, quick bootstrap.
  security.sudo.wheelNeedsPassword = false;

  # sd-image-aarch64.nix ships a root user with an empty password by
  # default; lock it down since this box is reachable over wifi.
  users.users.root.hashedPassword = "!";

  system.stateVersion = "26.11";
}
