_: {
  services.homepage-dashboard = {
    enable = true;
    # Fronted by caddy on :80 (nixos-server/modules/caddy) - no need for
    # this to be reachable directly from outside the host.
    openFirewall = false;
    listenPort = 8083;
    # caddy proxies the Host header through unchanged, so requests via
    # http://server.home arrive with no port suffix; the :8083
    # entries are for hitting this service directly for debugging.
    allowedHosts = "nixos-server.local,server.home,go,localhost,127.0.0.1,192.168.1.167,localhost:8083,127.0.0.1:8083";

    # Secrets (API keys/passwords) are NOT stored in the nix store.
    # Create this file on the server by hand after deploying, see nixos-server/homepage.nix comment below.
    environmentFiles = [ "/etc/homepage-dashboard-secrets.env" ];

    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];

    services = [
      {
        Media = [
          {
            Jellyfin = {
              icon = "jellyfin.png";
              href = "http://server.home:8096";
              description = "Media server";
              widget = {
                type = "jellyfin";
                url = "http://server.home:8096";
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
              };
            };
          }
          {
            MakeMKV = {
              icon = "mdi-disc";
              href = "http://server.home:5800";
              description = "Disc ripper";
            };
          }
        ];
      }
      {
        Downloads = [
          {
            qBittorrent = {
              icon = "qbittorrent.png";
              href = "http://server.home:8082";
              description = "Torrent client";
              widget = {
                type = "qbittorrent";
                url = "http://server.home:8082";
                username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
                password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
              };
            };
          }
        ];
      }
      {
        Network = [
          {
            "Pi-hole" = {
              icon = "pi-hole.png";
              # Pi-hole moved to the rpi (nixos-pihole) - resolved via its own
              # Pi-hole local DNS record now that mDNS/avahi isn't in the loop.
              href = "http://pihole.home";
              description = "DNS ad-blocker";
              widget = {
                type = "pihole";
                url = "http://pihole.home";
                version = 6;
                key = "{{HOMEPAGE_VAR_PIHOLE_KEY}}";
              };
            };
          }
        ];
      }
      {
        Nix = [
          {
            Attic = {
              icon = "mdi-package-variant-closed";
              href = "http://server.home:8081";
              description = "Nix binary cache";
            };
          }
        ];
      }
      {
        AI = [
          {
            Ollama = {
              icon = "ollama.png";
              href = "http://server.home:11434";
              description = "Local LLM server";
            };
          }
        ];
      }
    ];
  };
}
