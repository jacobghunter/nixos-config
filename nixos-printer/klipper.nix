# Klipper + Moonraker + Mainsail for the Sovol SV06, migrated from the
# Raspberry Pi OS install. Mainsail: http://nixos-printer.local
#
# Config lives in ./klipper (bassamanator/Sovol-SV06-firmware, GPL-3.0, with
# local edits). printer.cfg is Nix-managed: on every Klipper start the module
# rewrites it from ./klipper/printer.cfg but keeps the SAVE_CONFIG block
# (PID, z_offset, bed mesh) from the file on disk, so SAVE_CONFIG keeps
# working. Edits made in Mainsail's editor are lost on the next restart -
# change the files here and redeploy instead.
{ pkgs, ... }:

let
  # Everything Klipper and Moonraker share: printer.cfg + includes in config/,
  # gcode uploads in gcodes/ (matches [virtual_sdcard] in cfgs/misc-macros.cfg).
  dataDir = "/var/lib/moonraker";

  # Pinned to the exact commit the Raspberry Pi OS install ran with this
  # board's MCU firmware (v0.13.0-371). Host and MCU must agree on the command
  # protocol; staying on a known-good pair means no reflash. Moving to a newer
  # Klipper may need the board reflashed (via the printer's own SD slot).
  klipperVersion = "0.13.0-501-gc9d904aa9";
  klipper = pkgs.klipper.overrideAttrs (old: {
    version = klipperVersion;
    src = pkgs.fetchFromGitHub {
      owner = "Klipper3d";
      repo = "klipper";
      rev = "c9d904aa9d9de3ddb84a4c929f9d667c085329fc";
      hash = "sha256-wqgyecBkntDJBCF292fll+vBXuwWDlaY/ZLYzWyRKTE=";
    };
    # This commit predates the canboot -> katapult rename that nixpkgs'
    # installPhase expects (CAN-bus flash helper; unused here, but copied).
    installPhase =
      builtins.replaceStrings [ "lib/katapult/flashtool.py" ] [ "lib/canboot/flash_can.py" ]
        old.installPhase;
    # The upstream installPhase bakes the nixpkgs version into .version
    # before overrides apply; report the version actually running.
    postInstall = ''
      echo "v${klipperVersion}-NixOS" > $out/lib/klipper/.version
    '';
  });
in
{
  services = {
    klipper = {
      enable = true;
      package = klipper;
      # Run as moonraker so Moonraker/Mainsail can read the config, logs and
      # gcodes Klipper uses, and so SAVE_CONFIG writes land somewhere both see.
      user = "moonraker";
      group = "moonraker";
      configDir = "${dataDir}/config";
      configFile = ./klipper/printer.cfg;
      logFile = "${dataDir}/logs/klippy.log";
    };

    moonraker = {
      enable = true;
      address = "0.0.0.0";
      stateDir = dataDir;
      # Lets Mainsail's power menu reboot/shut down the Pi and restart services.
      allowSystemControl = true;
      settings = {
        authorization = {
          trusted_clients = [
            "10.0.0.0/8"
            "127.0.0.0/8"
            "169.254.0.0/16"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "100.64.0.0/10" # tailscale
            "FE80::/10"
            "::1/128"
          ];
          cors_domains = [
            "http://*.lan"
            "http://*.local"
            "http://*.home"
          ];
        };
        octoprint_compat = { };
        history = { };
        # Cancel-object support; see [exclude_object] in cfgs/misc-macros.cfg.
        file_manager.enable_object_processing = "True";
      };
    };

    mainsail.enable = true;
  };

  security.polkit.enable = true;

  systemd.tmpfiles.rules = [
    "d ${dataDir}/config 0775 moonraker moonraker - -"
    "d ${dataDir}/gcodes 0775 moonraker moonraker - -"
    "d ${dataDir}/logs 0775 moonraker moonraker - -"
    # printer.cfg's includes, read-only from the store.
    "L+ ${dataDir}/config/osskc.cfg - - - - ${./klipper/osskc.cfg}"
    "L+ ${dataDir}/config/cfgs - - - - ${./klipper/cfgs}"
    # First boot only ("C" never overwrites): seed printer.cfg with the
    # calibration carried over from the Raspberry Pi OS install. Klipper's
    # preStart then swaps in the Nix-managed body and keeps this SAVE_CONFIG.
    "C ${dataDir}/config/printer.cfg - - - - ${pkgs.concatText "printer-seed.cfg" [
      ./klipper/printer.cfg
      (pkgs.writeText "newline" "\n")
      ./klipper/save-config.cfg
    ]}"
  ];

  networking.firewall.allowedTCPPorts = [
    80 # mainsail (nginx)
    7125 # moonraker API, for slicers uploading directly
  ];
}
