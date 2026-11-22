# Local DNS records (hostname -> IP) served by every Pi-hole (nixos-pihole and
# the backup on nixos-server). Both must answer identically, otherwise a client
# that fails over to the backup stops resolving local names.
{
  # go-links + dashboard, both served by caddy on the server (nixos-server/modules/caddy)
  "go" = "192.168.1.167";
  "server.home" = "192.168.1.167";
  # Public Jellyfin domain, but straight to caddy on the LAN: no trip out
  # through the upload, and Jellyfin sees a LAN client so the remote bitrate
  # limit doesn't apply at home.
  "jellyfin.jacobghunter.com" = "192.168.1.167";
  # pi-hole itself
  "pihole.home" = "192.168.1.14";
  # 3D printer Pi (nixos-printer): Mainsail on 80, Moonraker API on 7125
  "printer.home" = "192.168.1.140";
}
