{ lib, ... }: {
  # NETWORK CONFIGURATION
  networking = {
    hosts = {
      "192.168.1.1" = ["gateway.homelab.me" "gateway"];
      "192.168.1.167" = ["pi-hole.homelab.me" "pi-hole"];
    };
  };

  services = {
    # DISABLE separate dnsmasq (Pi-hole provides its own)
    dnsmasq = {
      enable = false; 
    };

    # PI-HOLE FTL ENGINE
    pihole-ftl = {
      enable = true;
      lists = [
        {
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          type = "block";
          enabled = true;
          description = "Steven Black's HOSTS";
        }
      ];
      # Open Firewall ports automatically
      openFirewallDNS = true;
      openFirewallDHCP = true;
      openFirewallWebserver = true;
      
      settings = {
        # TEMPORARY, ALLOWS SETTING WEB PASSWORD
        # misc.readOnly = false;

        # DHCP SERVER (Default is OFF - set active=true if you want Pi-hole to be your router's DHCP)
        dhcp = {
          active = false; 
          router = "192.168.1.1"; # Your Router IP
        };
        
        # DNS CONFIGURATION
        dns = {
          domain = "homelab.me";
          interface = "enp1s0"; # Check your interface name (run `ip a`)
          upstreams = ["1.1.1.1" "1.1.1.2"]; # Cloudflare upstream
        };
        
        # WEBSERVER CONFIG
        webserver = {
          api = {
            # Hashed password goes here (See Step 3 below)
            pwhash = "$BALLOON-SHA256$v=1$s=1024,t=32$kVqB62qUpnPUQulGDapmBA==$pFYWzIfOzQKS+vs6LcQPz9wfqhkJANVE8pD+PvwumFI="; 
          };
          session.timeout = 43200; # 12 hours
        };
      };
      useDnsmasqConfig = true;
    };

    # PI-HOLE WEB INTERFACE
    pihole-web = {
      enable = true;
      ports = [80]; 
    };

    # DISABLE SYSTEMD-RESOLVED STUB (Conflicts with Pi-hole on port 53)
    resolved = {
      enable = true;
      settings = {
        "Resolve" = {
          "DNSStubListener" = "no";
          "MulticastDNS" = "no";
        };
      };
    };
  };

  # Fix for a benign FTL log warning
  systemd.tmpfiles.rules = [
    "f /etc/pihole/versions 0644 pihole pihole - -"
  ];
}
