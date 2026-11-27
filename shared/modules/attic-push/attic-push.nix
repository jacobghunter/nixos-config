{ pkgs, inputs, ... }:
let
  attic-client = inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic-client;

  # Waits (as a running service, not a failing one) until the cache answers,
  # then hands over to watch-store.
  watchStore = pkgs.writeShellScript "attic-watch-store" ''
    until ${pkgs.curl}/bin/curl -sf -m 5 -o /dev/null http://192.168.1.167:8081/nixos-config/nix-cache-info; do
      sleep 30
    done
    exec ${attic-client}/bin/attic watch-store nixos-config
  '';
in
{
  environment.systemPackages = [ attic-client ];

  # `attic login server https://192.168.1.167:8081 <push-token>` must be
  # run once, manually, as root on this machine to populate
  # /root/.config/attic/config.toml - that's a credential and can't be
  # provisioned through the Nix store.
  #
  # Pushes to the attic server (nixos-server/modules/attic) from a background
  # service that watches /nix/store, rather than a nix post-build-hook. Nix
  # runs that hook synchronously and stalls the build until it returns, so a
  # separate `attic push` per derivation (a second or two each, even for a
  # few-KB file) added minutes to every rebuild, and a slow link (the laptop
  # on Wi-Fi) or an unreachable server stalled it far worse. Here a rebuild
  # never waits on the cache. watch-store also picks up substituted paths
  # (e.g. from hyprland.cachix.org), skipping ones signed by cache.nixos.org.
  #
  # Off the home LAN (without Tailscale) the server is unreachable, so the
  # service polls it every 30s and only starts watch-store once it answers.
  # watch-store exiting on its own would leave the unit in auto-restart, which
  # switch-to-configuration reports as failed on every rebuild away from home.
  # If the connection drops later, watch-store exits and is restarted back
  # into the wait. Paths added while away are not backfilled - a one-off
  # `sudo attic push nixos-config /run/current-system` catches them up.
  systemd.services.attic-watch-store = {
    description = "Push new Nix store paths to the attic cache";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    # Never stop retrying, however long the server stays unreachable.
    startLimitIntervalSec = 0;

    # Not logged in yet: stay inactive rather than restart-looping.
    unitConfig.ConditionPathExists = "/root/.config/attic/config.toml";

    # Root's attic config lives under $HOME, which systemd leaves unset for
    # services without User=.
    environment.HOME = "/root";

    serviceConfig = {
      ExecStart = watchStore;
      Restart = "always";
      RestartSec = "30s";
      # Uploads are background work - never compete with a build or the desktop.
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
}
