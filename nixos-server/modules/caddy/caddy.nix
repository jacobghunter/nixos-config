{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.caddy;
in
{
  options.modules.caddy = {
    enable = lib.mkEnableOption "Caddy reverse proxy for LAN services (homepage catch-all on :80, go-links)";

    publicJellyfin = {
      enable = lib.mkEnableOption "expose Jellyfin to the wider internet as HTTPS on a Cloudflare-fronted domain";

      domain = lib.mkOption {
        type = lib.types.str;
        default = "jellyfin.jacobghunter.com";
        description = "Public hostname to serve Jellyfin on. Must have a Cloudflare-proxied DNS record pointing at this host.";
      };

      upstream = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:8096";
        description = "Address Jellyfin is actually listening on.";
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          EnvironmentFile (systemd) supplying CF_API_TOKEN, used by the
          caddy-dns/cloudflare plugin to complete the DNS-01 challenge.
          Required when publicJellyfin.enable is true.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.publicJellyfin.enable -> cfg.publicJellyfin.environmentFile != null;
        message = "modules.caddy.publicJellyfin.environmentFile must be set when modules.caddy.publicJellyfin.enable is true (it supplies CF_API_TOKEN for the Cloudflare DNS-01 challenge).";
      }
    ];

    services.caddy = {
      enable = true;
      openFirewall = true;

      package =
        if cfg.publicJellyfin.enable then
          pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
            hash = lib.fakeHash; # build once, paste the real hash from the error
          }
        else
          pkgs.caddy;

      environmentFile = lib.mkIf cfg.publicJellyfin.enable cfg.publicJellyfin.environmentFile;

      virtualHosts = {
        # Single-site box - catch-all on :80 instead of a hostname-matched vhost,
        # so this works regardless of Host header (IP access, mDNS failures, etc).
        ":80".extraConfig = ''
          reverse_proxy 127.0.0.1:8083
        '';

        # go-links: "go" needs a DNS A record (e.g. in Pi-hole) pointing at this
        # host. Then http://go/<name> jumps straight to a service - no bookmark,
        # no typing the LAN hostname/port. Keep in sync with homepage.nix hrefs.
        "go:80".extraConfig = ''
          redir /home http://server.home
          redir /jellyfin http://server.home:8096
          redir /books http://server.home:8085
          redir /makemkv http://server.home:5800
          redir /qbittorrent http://server.home:8082
          redir /pihole http://pihole.home
          redir /attic http://server.home:8081
          redir /ollama http://server.home:11434
        '';
      }
      // lib.optionalAttrs cfg.publicJellyfin.enable {
        "${cfg.publicJellyfin.domain}".extraConfig = ''
          tls {
            dns cloudflare {env.CF_API_TOKEN}
          }
          reverse_proxy ${cfg.publicJellyfin.upstream}
        '';
      };
    };
  };
}
