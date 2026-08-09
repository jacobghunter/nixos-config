{ ... }:
{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    listenPort = 8082;
    allowedHosts = "nixos-server.local:8082,localhost:8082,127.0.0.1:8082";

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
              href = "http://nixos-server.local:8096";
              description = "Media server";
              widget = {
                type = "jellyfin";
                url = "http://nixos-server.local:8096";
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
              };
            };
          }
        ];
      }
      {
        Downloads = [
          {
            qBittorrent = {
              icon = "qbittorrent.png";
              href = "http://nixos-server.local:8080";
              description = "Torrent client";
              widget = {
                type = "qbittorrent";
                url = "http://nixos-server.local:8080";
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
              href = "http://nixos-server.local";
              description = "DNS ad-blocker";
              widget = {
                type = "pihole";
                url = "http://nixos-server.local";
                version = 6;
                key = "{{HOMEPAGE_VAR_PIHOLE_KEY}}";
              };
            };
          }
        ];
      }
      {
        AI = [
          {
            Ollama = {
              icon = "ollama.png";
              href = "http://nixos-server.local:11434";
              description = "Local LLM server";
            };
          }
        ];
      }
    ];
  };
}
