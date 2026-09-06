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
  # retry for 100+ seconds. `timeout` below bounds that per build output.
  nix.settings.post-build-hook = "${pkgs.writeShellScript "attic-push" ''
    set -f # disable globbing
    ${pkgs.coreutils}/bin/timeout 15 ${attic-client}/bin/attic push nixos-config $OUT_PATHS || {
      echo "attic-push: failed to push to nixos-config (unreachable or timed out), continuing anyway" >&2
      exit 0
    }
  ''}";
}
