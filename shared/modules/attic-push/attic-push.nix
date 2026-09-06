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
  nix.settings.post-build-hook = "${pkgs.writeShellScript "attic-push" ''
    set -f # disable globbing
    ${attic-client}/bin/attic push nixos-config $OUT_PATHS || {
      echo "attic-push: failed to push to nixos-config, continuing anyway" >&2
      exit 0
    }
  ''}";
}
