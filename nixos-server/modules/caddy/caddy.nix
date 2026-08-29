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
  };
}
