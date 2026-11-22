_:

{
  networking = {
    hostName = "nixos-pihole";
  };

  # nixos-hardware's raspberry-pi-5 module needs generic-extlinux-compatible
  # (u-boot chainloading extlinux.conf), but their newer firmware.nix module
  # only stages u-boot.bin onto the sd-image when this is explicitly enabled
  # - it defaults to off, which silently produces an unbootable firmware
  # partition (no u-boot.bin, no `kernel=` line in config.txt).
  hardware.raspberry-pi.firmware.uboot.enable = true;

  # sd-image-aarch64 pulls in the generic aarch64 initrd module list (e.g.
  # dw-hdmi, for other SoCs), which linux-rpi doesn't build, so the initrd's
  # module closure fails. nixos-hardware's raspberry-pi-3 module carries this
  # same overlay; its raspberry-pi-5 module doesn't.
  nixpkgs.overlays = [
    (_final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  # avahi (for `ssh jacob@nixos-pihole.local`), users.users.jacob + its
  # authorized keys, services.openssh.enable, and nix.settings.trusted-users
  # all now come from shared/configuration.nix instead of being duplicated
  # here - that duplication is exactly what let the pi's authorized keys
  # drift out of sync with the shared list.
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
  };

  # No sudo password — local network only, quick bootstrap.
  security.sudo.wheelNeedsPassword = false;

  # sd-image-aarch64.nix ships a root user with an empty password by
  # default; lock it down since this box is reachable over wifi.
  users.users.root.hashedPassword = "!";

  system.stateVersion = "25.05";
}
