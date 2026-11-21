# Local DNS records (hostname -> IP) served by every Pi-hole (nixos-pihole and
# the backup on nixos-server). Both must answer identically, otherwise a client
# that fails over to the backup stops resolving local names.
{
  # go-links + dashboard, both served by caddy on the server (nixos-server/modules/caddy)
  "go" = "192.168.1.167";
  "server.home" = "192.168.1.167";
  # pi-hole itself
  "pihole.home" = "192.168.1.14";
}
