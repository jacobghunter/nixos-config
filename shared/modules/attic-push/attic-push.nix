{ pkgs, inputs, ... }:
let
  attic-client = inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic-client;

  # The attic server (nixos-server/modules/attic) - same host:port as the
  # substituter in shared/configuration.nix.
  cacheHost = "192.168.1.167";
  cachePort = "8081";
in
{
  environment.systemPackages = [ attic-client ];

  # `attic login server https://192.168.1.167:8081 <push-token>` must be
  # run once, manually, as root on this machine to populate
  # /root/.config/attic/config.toml - that's a credential and can't be
  # provisioned through the Nix store.
  #
  # A failing post-build-hook fails the *entire* build/rebuild that
  # triggered it, so this must never exit non-zero - push is best-effort,
  # not a build requirement.
  #
  # `attic push` has no --connect-timeout of its own, and when the server is
  # unreachable (off the home LAN, server down) the connection attempt just
  # hangs - confirmed a bare TCP connect to it can sit for 40s+ without even
  # failing, since Linux's tcp_syn_retries default lets an unanswered SYN
  # retry for 100+ seconds. So reachability is checked separately with a
  # short bare TCP connect first, and only *that* failing marks the cache
  # unreachable. The push itself gets a long timeout - it's only a backstop
  # against a hang mid-upload; bounding the whole push to a few seconds
  # killed big outputs (a 47 MB pi kernel over Wi-Fi) partway through and
  # wrongly marked a reachable server as down.
  #
  # A single rebuild can trigger this hook once per newly-built derivation,
  # so the marker file remembers an unreachable server for 5 minutes and the
  # rest of *this* rebuild skips straight past every subsequent push instead
  # of re-paying the connect timeout per derivation - short-lived and in /run
  # (cleared on reboot) so reconnecting to the home network gets retried on
  # its own before long.
  nix.settings.post-build-hook = "${pkgs.writeShellScript "attic-push" ''
    set -f # disable globbing
    marker=/run/attic-push-unreachable

    if [ -n "$(${pkgs.findutils}/bin/find "$marker" -mmin -5 2>/dev/null)" ]; then
      echo "attic-push: skipping, marked unreachable within the last 5 min" >&2
      exit 0
    fi

    if ! ${pkgs.coreutils}/bin/timeout 3 ${pkgs.bash}/bin/bash -c ': </dev/tcp/${cacheHost}/${cachePort}' 2>/dev/null; then
      touch "$marker"
      echo "attic-push: cache unreachable, skipping further pushes for 5 min" >&2
      exit 0
    fi
    rm -f "$marker"

    if ! ${pkgs.coreutils}/bin/timeout 600 ${attic-client}/bin/attic push nixos-config $OUT_PATHS; then
      echo "attic-push: failed to push to nixos-config, continuing anyway" >&2
    fi
    exit 0
  ''}";
}
