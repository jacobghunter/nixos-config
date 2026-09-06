{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [
    9090 # Calibre Wireless Connection
    8080 # Calibre Content Server
  ];

  services.udev.packages = [ pkgs.calibre ];
}
