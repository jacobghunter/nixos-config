_: {
  services.caddy = {
    enable = true;
    httpsPort = null; # LAN-only, no public domain to get a cert for
    openFirewall = true;

    # Single-site box - catch-all on :80 instead of a hostname-matched vhost,
    # so this works regardless of Host header (IP access, mDNS failures, etc).
    virtualHosts.":80".extraConfig = ''
      reverse_proxy 127.0.0.1:8083
    '';

    # go-links: "go" needs a DNS A record (e.g. in Pi-hole) pointing at this
    # host. Then http://go/<name> jumps straight to a service - no bookmark,
    # no typing the LAN hostname/port. Keep in sync with homepage.nix hrefs.
    virtualHosts."go:80".extraConfig = ''
      redir /home http://server.home
      redir /jellyfin http://server.home:8096
      redir /makemkv http://server.home:5800
      redir /qbittorrent http://server.home:8082
      redir /pihole http://pihole.home
      redir /attic http://server.home:8081
      redir /ollama http://server.home:11434
    '';
  };
}
