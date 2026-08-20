{
  modules.pihole = {
    enable = true;
    interface = "enp1s0"; # Check your interface name (run `ip a`)
    webPasswordHash = "$BALLOON-SHA256$v=1$s=1024,t=32$kVqB62qUpnPUQulGDapmBA==$pFYWzIfOzQKS+vs6LcQPz9wfqhkJANVE8pD+PvwumFI=";
  };

  networking.hosts."192.168.1.167" = [
    "pi-hole.homelab.me"
    "pi-hole"
  ];
}
