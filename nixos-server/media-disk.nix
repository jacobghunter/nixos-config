{ lib, pkgs, ... }:

# 6TB Seagate Expansion (USB, ST6000DM003 BarraCuda SMR inside) holding the
# media library. The SSD stays system + nix store + attic cache.
#
# Deliberately NOT in disk-config.nix: disko would wipe it on a reinstall.
# Created by hand: one GPT partition, then
#   mkfs.ext4 -L media -m 0 -T largefile -E lazy_itable_init=0,lazy_journal_init=0
let
  mountPoint = "/media/storage";
  diskId = "ata-ST6000DM003-2ZD186_ZSB06A2R";

  # smartd alert -> phone (ntfy.sh) + wall. The topic lives in /etc/ntfy.env
  # (root-only, not in this public repo) as NTFY_URL=https://ntfy.sh/<topic>;
  # subscribe to that topic in the ntfy app. Scrutiny reads the same file.
  ntfyAlert = pkgs.writeShellScript "smartd-ntfy" ''
    ${pkgs.util-linux}/bin/wall "$SMARTD_FULLMESSAGE" || true
    . /etc/ntfy.env
    ${lib.getExe pkgs.curl} -fsS --retry 3 -o /dev/null \
      -H "Title: $SMARTD_SUBJECT" -H "Priority: high" -H "Tags: warning,cd" \
      -d "$SMARTD_FULLMESSAGE" "$NTFY_URL"
  '';
in
{
  # The enclosure's UAS mode rejects ATA passthrough, so SMART is unreadable.
  # Force plain usb-storage for it (~160 MB/s, plenty for streaming).
  boot.kernelParams = [ "usb-storage.quirks=0bc2:203b:u" ];

  # nofail: a missing/unplugged drive doesn't drop boot into emergency mode.
  fileSystems.${mountPoint} = {
    device = "/dev/disk/by-label/media";
    fsType = "ext4";
    options = [
      "noatime"
      "nofail"
      "x-systemd.device-timeout=30s"
    ];
  };

  # Without the drive these would start against the empty directory underneath
  # the mountpoint on the SSD (Jellyfin would drop the library, rips would land
  # on the SSD). Fail them instead.
  systemd.services =
    lib.genAttrs
      [
        "jellyfin"
        "calibre-web"
        "docker-makemkv"
      ]
      (_: {
        unitConfig.RequiresMountsFor = mountPoint;
      })
    // {
      # The USB drive enumerates a few seconds after smartd would otherwise
      # start; wait for its mount (Wants, not Requires: the SSD still gets
      # monitored if the drive is unplugged).
      smartd = {
        wants = [ "media-storage.mount" ];
        after = [ "media-storage.mount" ];
      };
    };

  services.smartd = {
    enable = true;
    autodetect = false;
    devices = [
      {
        # -d sat: SMART passthrough via the USB bridge. Short test weekly
        # (Sun 03:00), long test monthly (1st, 04:00, ~13h). Warn at 50C,
        # critical at 55C. -d removable: if the drive is missing at startup,
        # skip it instead of exiting (which also dropped SSD monitoring).
        device = "/dev/disk/by-id/${diskId}";
        options = "-d sat -d removable -a -o on -S on -n standby,q -s (S/../../7/03|L/../01/./04) -W 4,50,55 -M exec ${ntfyAlert}";
      }
      {
        device = "/dev/disk/by-id/ata-Micron_M500_MTFDDAK960MAV_130602043E0D";
        options = "-a -o on -S on -s (S/../../7/02) -W 4,55,65 -M exec ${ntfyAlert}";
      }
    ];
  };
}
