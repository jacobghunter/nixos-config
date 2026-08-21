{
  # Static IP on ethernet so DNS clients always find pi-hole at the same
  # address, even if the router (or its DHCP reservation for this MAC) ever
  # changes. Wifi stays on DHCP as a fallback path - not used for DNS.
  networking.interfaces.enu1u1 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.14";
        prefixLength = 24;
      }
    ];
  };

  # Without its own default gateway, packets sourced from enu1u1's static
  # IP have nowhere to go for anything off-subnet (e.g. upstream DNS at
  # 1.1.1.1) even though wlan0 has a perfectly good default route - the
  # kernel won't use wlan0's route for traffic bound to enu1u1's address.
  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = "enu1u1";
  };

  modules.pihole = {
    enable = true;
    interface = "enu1u1"; # Pi 3B's onboard ethernet - USB-attached, so it's "enu1u1" not "enp1s0"/"eth0"
    webPasswordHash = "$BALLOON-SHA256$v=1$s=1024,t=32$kVqB62qUpnPUQulGDapmBA==$pFYWzIfOzQKS+vs6LcQPz9wfqhkJANVE8pD+PvwumFI=";
  };

  networking.hosts."192.168.1.14" = [
    "pi-hole.homelab.me"
    "pi-hole"
  ];
}
