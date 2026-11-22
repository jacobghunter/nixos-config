# Wifi for the Raspberry Pi hosts, with the SSID + PSK kept out of git (this
# repo is public) and the Nix store. No networks are declared here:
# wpa_supplicant reads them from /etc/wpa_supplicant/imperative.conf on the
# device, which scripts/pi-image.sh writes - baked into a fresh SD image, or
# pushed to a running Pi with `--push`. Nix never manages that file, so
# deploys leave it alone and a Pi can move networks without a rebuild.
{ config, pkgs, ... }:

{
  networking.wireless = {
    enable = true;
    # Needed to unlock the Pi 3's wifi radio - without a country set,
    # wpa_supplicant won't associate.
    extraConfig = "country=US";
    allowAuxiliaryImperativeNetworks = true;
  };

  # The Pi 3's wifi chip needs its (redistributable) firmware blob.
  hardware.enableRedistributableFirmware = true;

  # A deploy that leaves wpa_supplicant with no network knocks a headless Pi
  # off wifi until someone plugs in a screen or cable - e.g. migrating a Pi
  # that used to declare its network in Nix before its imperative.conf
  # exists. Refuse to switch instead. grep by store path: pre-switch checks
  # run with a minimal PATH, and a missing grep would read as "no network".
  system.preSwitchChecks.piWifiNetwork = ''
    if [ "$2" != "dry-activate" ] && ! ${pkgs.gnugrep}/bin/grep -qs '^network={' /etc/wpa_supplicant/imperative.conf; then
      echo "pi-wifi: /etc/wpa_supplicant/imperative.conf has no wifi network;" >&2
      echo "pi-wifi: switching would take this Pi offline. Run" >&2
      echo "pi-wifi:   scripts/pi-image.sh --push ${config.networking.hostName}" >&2
      echo "pi-wifi: first, then deploy again." >&2
      exit 1
    fi
  '';
}
