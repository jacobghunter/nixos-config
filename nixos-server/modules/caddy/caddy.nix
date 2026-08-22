_: {
  services.caddy = {
    enable = true;
    httpsPort = null; # LAN-only, no public domain to get a cert for
    openFirewall = true;

    virtualHosts."http://nixos-server.local".extraConfig = ''
      reverse_proxy 127.0.0.1:8083
    '';
  };
}
