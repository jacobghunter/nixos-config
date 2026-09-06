{ pkgs, inputs, ... }:
let
  attic-client = inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic-client;
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
  # retry for 100+ seconds. `timeout` bounds that per build output, but a
  # single rebuild can trigger this hook once per newly-built derivation, so
  # even a bounded timeout adds up fast off the home LAN. The marker file
  # below remembers a timeout for 5 minutes so the rest of *this* rebuild
  # skips straight past every subsequent push instead of re-paying the
  # timeout per derivation - short-lived and in /run (cleared on reboot) so
  # reconnecting to the home network gets retried on its own before long.
  nix.settings.post-build-hook = "${pkgs.writeShellScript "attic-push" ''
    set -f # disable globbing
    marker=/run/attic-push-unreachable

    if [ -n "$(${pkgs.findutils}/bin/find "$marker" -mmin -5 2>/dev/null)" ]; then
      echo "attic-push: skipping, marked unreachable within the last 5 min" >&2
      exit 0
    fi

    if ${pkgs.coreutils}/bin/timeout 15 ${attic-client}/bin/attic push nixos-config $OUT_PATHS; then
      rm -f "$marker"
    else
      status=$?
      if [ "$status" -eq 124 ]; then
        touch "$marker"
        echo "attic-push: timed out reaching the cache, skipping further pushes for 5 min" >&2
      else
        echo "attic-push: failed to push to nixos-config, continuing anyway" >&2
      fi
    fi
    exit 0
  ''}";
}
