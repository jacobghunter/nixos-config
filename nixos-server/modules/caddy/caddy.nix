{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.caddy;

  # Any public vhost needs the Cloudflare DNS plugin + token for its cert.
  anyPublic = cfg.publicJellyfin.enable || cfg.publicCalibreKobo.enable;
in
{
  options.modules.caddy = {
    enable = lib.mkEnableOption "Caddy reverse proxy for LAN services (homepage catch-all on :80, go-links)";

    cloudflareEnvironmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        EnvironmentFile (systemd) supplying CF_API_TOKEN, used by the
        caddy-dns/cloudflare plugin to complete the DNS-01 challenge.
        Required when any public* vhost is enabled - shared between them
        since services.caddy only takes one environment file.
      '';
    };

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
    };

    publicCalibreKobo = {
      enable = lib.mkEnableOption ''
        Calibre-Web's Kobo Sync API (/kobo/*) on a public HTTPS domain, so the
        Kobo can sync away from home. Everything else on that host 404s - the
        web UI stays LAN/Tailscale-only, since /kobo/* is the only part gated
        by the per-user sync token rather than a password login page
      '';

      domain = lib.mkOption {
        type = lib.types.str;
        default = "calibre.jacobghunter.com";
        description = "Public hostname to serve Kobo Sync on. Must have a Cloudflare-proxied DNS record pointing at this host.";
      };

      upstream = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:8085";
        description = "Address Calibre-Web is actually listening on.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = anyPublic -> cfg.cloudflareEnvironmentFile != null;
        message = "modules.caddy.cloudflareEnvironmentFile must be set when a modules.caddy.public* vhost is enabled (it supplies CF_API_TOKEN for the Cloudflare DNS-01 challenge).";
      }
    ];

    services.caddy = {
      enable = true;
      openFirewall = true;

      package =
        if anyPublic then
          pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
            hash = "sha256-8yZDrejNKsaUnUaTUFYbarWNmxafqp2z2rWo+XRsxV8="; # build once, paste the real hash from the error
          }
        else
          pkgs.caddy;

      environmentFile = lib.mkIf anyPublic cfg.cloudflareEnvironmentFile;

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
      }
      // lib.optionalAttrs cfg.publicCalibreKobo.enable {
        # Caddy's default X-Forwarded-Host marks the request as proxied to
        # calibre-web (cps/reverseproxy.py), so it builds the Kobo's download
        # and cover URLs from url_for(_external=True) instead of LAN host +
        # config_external_port. X-Scheme is what it reads for the scheme -
        # without it those URLs come back as http:// on the public domain.
        "${cfg.publicCalibreKobo.domain}".extraConfig = ''
          tls {
            dns cloudflare {env.CF_API_TOKEN}
          }
          handle /kobo/* {
            reverse_proxy ${cfg.publicCalibreKobo.upstream} {
              header_up X-Scheme https
            }
          }
          handle {
            respond 404
          }
        '';
      };
    };
  };
}
