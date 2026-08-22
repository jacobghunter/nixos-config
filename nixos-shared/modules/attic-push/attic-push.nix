{ pkgs, inputs, ... }:
let
  attic-client = inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic-client;
in
{
  environment.systemPackages = [ attic-client ];

  # `attic login server https://nixos-server.local:8081 <push-token>` must be
  # run once, manually, as root on this machine to populate
  # /root/.config/attic/config.toml - that's a credential and can't be
  # provisioned through the Nix store.
  nix.settings.post-build-hook = "${pkgs.writeShellScript "attic-push" ''
    set -eu
    set -f # disable globbing
    exec ${attic-client}/bin/attic push nixos-config $OUT_PATHS
  ''}";
}
