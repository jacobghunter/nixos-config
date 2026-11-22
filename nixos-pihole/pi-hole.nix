{
  networking = {
    # Static IP on ethernet so DNS clients always find pi-hole at the same
    # address, even if the router (or its DHCP reservation for this MAC) ever
    # changes. Wifi stays on DHCP as a fallback path - not used for DNS.
    interfaces.end0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.1.14";
          prefixLength = 24;
        }
      ];
    };

    # Without its own default gateway, packets sourced from end0's static
    # IP have nowhere to go for anything off-subnet (e.g. upstream DNS at
    # 1.1.1.1) even though wlan0 has a perfectly good default route - the
    # kernel won't use wlan0's route for traffic bound to end0's address.
    defaultGateway = {
      address = "192.168.1.1";
      interface = "end0";
    };

    hosts."192.168.1.14" = [
      "pi-hole.homelab.me"
      "pi-hole"
    ];
  };
  modules.pihole = {
    enable = true;
    interface = "end0"; # Pi 5's onboard ethernet (macb, predictable name "end0")
    # Password and local DNS records come from the shared module defaults
    # (shared/modules/pihole), so the backup on nixos-server stays identical.
  };
}
