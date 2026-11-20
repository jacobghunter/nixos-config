#!/usr/bin/env bash
# Wifi for the Raspberry Pi hosts (nixos-pihole, nixos-parents, ...) without
# putting the SSID or password in git (this repo is public) or the Nix store.
# shared/modules/pi-wifi declares no networks; wpa_supplicant reads them from
# /etc/wpa_supplicant/imperative.conf on the device instead, which this
# script writes.
#
#   scripts/pi-image.sh <host>          Build <host>'s SD image with the wifi
#                                       network baked in, so it joins on first
#                                       boot with no cable, keyboard or screen.
#                                       Output: <host>/<host>.img (gitignored).
#   scripts/pi-image.sh --push <host>   Write the network onto an already
#                                       running Pi over ssh. Do this BEFORE
#                                       deploying a config that drops a
#                                       declared network, or it falls off wifi.
#
# Building aarch64 images needs boot.binfmt.emulatedSystems (pc + laptop).
# Flash with: caligula burn <host>/<host>.img   (only offers removable drives)
set -euo pipefail

usage() {
  echo "usage: $0 [--push] <host>   e.g. $0 nixos-parents" >&2
  exit 1
}

push=0
if [ "${1:-}" = "--push" ]; then
  push=1
  shift
fi
[ $# -eq 1 ] || usage
host="$1"

repo="$(cd "$(dirname "$0")/.." && pwd)"
[ -d "$repo/$host" ] || {
  echo "No $host/ directory in $repo." >&2
  exit 1
}

read -rp "Wifi SSID for $host: " ssid
read -rsp "Wifi password: " psk
echo
read -rsp "Again: " psk2
echo
if [ "$psk" != "$psk2" ]; then
  echo "Passwords don't match." >&2
  exit 1
fi
if [ "${#psk}" -lt 8 ] || [ "${#psk}" -gt 63 ]; then
  echo "WPA passwords are 8-63 characters." >&2
  exit 1
fi

# Same derivation wpa_passphrase does (PBKDF2-HMAC-SHA1, SSID as salt), so the
# device stores the 64-hex PSK rather than the password itself. Done here
# because wpa_passphrase insists on a tty for stdin, and passing the password
# as an argument would expose it in the process list. SSID written as hex so
# quotes or odd characters in it can't break the config.
network="$(printf '%s\n%s' "$ssid" "$psk" | python3 -c '
import hashlib, sys
ssid, psk = sys.stdin.read().split("\n", 1)
key = hashlib.pbkdf2_hmac("sha1", psk.encode(), ssid.encode(), 4096, 32).hex()
print("network={\n  ssid=%s\n  psk=%s\n}" % (ssid.encode().hex(), key))
')"
unset psk psk2

# Writes stdin to $1/etc/wpa_supplicant/imperative.conf as root. NixOS's
# wpa_supplicant unit re-owns it to wpa_supplicant on start. The dirs are
# made 0755 *before* tightening the umask: a fresh SD image has no /etc yet,
# and a root-only /etc locks every non-root service (wpa_supplicant runs as
# its own user) out of its config - the Pi then never joins wifi.
# shellcheck disable=SC2016 # $1 is expanded by the inner sh, not here
write_conf='mkdir -p -m 755 "$1/etc" "$1/etc/wpa_supplicant"; umask 077; cat > "$1/etc/wpa_supplicant/imperative.conf"'

if [ "$push" = 1 ]; then
  echo "Writing network to $host over ssh..."
  # shellcheck disable=SC2029 # write_conf is meant to be sent as-is
  printf '%s\n' "$network" | ssh "$host" "sudo sh -c '$write_conf' _ ''"
  echo "Done. Deploy with: rebuild $host"
  exit 0
fi

out_img="$repo/$host/$host.img"

echo "Building SD image..."
# git flake ref (not path:) so untracked/ignored files like old .img files
# aren't copied into the store - $host/ must be `git add`ed.
sd_image="$(nix build --no-link --print-out-paths \
  "$repo#nixosConfigurations.$host.config.system.build.sdImage")"

echo "Decompressing to $out_img..."
nix shell nixpkgs#zstd -c zstd -d -f "$sd_image"/sd-image/*.img.zst -o "$out_img"

echo "Writing wifi network into the image (sudo)..."
loop="$(sudo losetup --find --show --partscan "$out_img")"
mnt="$(mktemp -d)"
cleanup() {
  sudo umount "$mnt" 2>/dev/null || true
  sudo losetup -d "$loop" 2>/dev/null || true
  rmdir "$mnt" 2>/dev/null || true
}
trap cleanup EXIT

# Partition 2 is the NIXOS_SD root filesystem (partition 1 is FIRMWARE).
sudo mount "${loop}p2" "$mnt"
printf '%s\n' "$network" | sudo sh -c "$write_conf" _ "$mnt"

echo "Done: $out_img"
