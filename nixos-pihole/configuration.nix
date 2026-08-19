{ lib, ... }:

{
  networking.hostName = "nixos-pihole";

  # --- WiFi ---
  # Quick and dirty: plaintext psk in the nix store (world-readable on the
  # Pi, and it'll end up in your git history once this gets folded into the
  # monorepo). Fine for getting SSH access; swap to
  # `networking.wireless.environmentFile` + agenix/sops before this is
  # anything more than a bootstrap image.
  # Needed to unlock the Pi 3's wifi radio - without a country set,
  # wpa_supplicant won't associate.
  networking.wireless.extraConfig = "country=US";
  hardware.enableRedistributableFirmware = true;

  networking.wireless = {
    enable = true;
    networks."Weefee_2.4G" = {
      psk = "mightyskates216";
    };
  };

  # Lets you `ssh jacob@nixos-pihole.local` instead of hunting for the DHCP
  # lease in your router's client list.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # --- SSH ---
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # No sudo password — local network only, quick bootstrap.
  security.sudo.wheelNeedsPassword = false;

  users.users.jacob = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSF1X9Rhk/20YAwdqLI5zlZSIIZjL06/Rri8UZqv/Or jacob@nixos-laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFX1rPVicE6akrUGmXwuP5C2qmLtJ22E+Od1ZsU/on0H jacob@Jacobs-PC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0WYLgYAAWBISrS7w+QTxPohk4xb8kHbBQIwlJWMCiY jacob@nixos-wsl"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENlOaDve6NsoV4BfHjM0xbNnfwPOZzm4FQ+up6eHz9d jacob@nixos-pc"
    ];
  };

  # sd-image-aarch64.nix ships a root user with an empty password by
  # default; lock it down since this box is reachable over wifi.
  users.users.root.hashedPassword = "!";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.05";
}
