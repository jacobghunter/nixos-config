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
