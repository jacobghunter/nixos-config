#!/usr/bin/env bash
# One-time bootstrap for a fresh attic instance: mints an admin token, logs
# in, creates the cache, makes it public, and configures the upstream-cache
# filter so `attic push` skips paths already signed by cache.nixos.org or
# our cachix caches instead of re-uploading them. Then repeatedly mints
# push-only client tokens on request.
#
# Run manually on the server after atticd is up (`rebuild` first). Not part
# of system activation - re-running the setup half mints a brand new admin
# token every time, which is fine, but it's an imperative admin action, not
# config.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Must run as root (needs /etc/atticd.env and writes to /root/.config/attic)." >&2
  exec sudo "$0" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

CACHE_NAME="nixos-config"
SERVER_URL="http://nixos-server.local:8081"

echo "==> Minting admin token for '$CACHE_NAME'"
TOKEN=$(atticd-atticadm make-token --sub jacob-admin --validity '10 years' \
  --create-cache "$CACHE_NAME" \
  --configure-cache "$CACHE_NAME" \
  --configure-cache-retention "$CACHE_NAME" \
  --push "$CACHE_NAME" \
  --pull "$CACHE_NAME" \
  --delete "$CACHE_NAME")

echo "==> Logging in to $SERVER_URL"
attic login server "$SERVER_URL" "$TOKEN"

echo "==> Creating cache '$CACHE_NAME' (ok if it already exists)"
attic cache create "$CACHE_NAME" || true

# Pulled from flake.nix's nixConfig.extra-trusted-public-keys instead of
# hardcoded, so adding/removing a cachix cache there is the only place that
# needs to change - cache.nixos.org-1 isn't in that list (it's not a flake
# input substituter), so it's added separately.
echo "==> Reading cachix cache keys from $REPO_DIR/flake.nix"
mapfile -t CACHIX_KEYS < <(nix eval --impure --raw --expr "
  builtins.concatStringsSep \"\n\" (
    map (k: builtins.elemAt (builtins.match \"([^:]*):.*\" k) 0)
      (import ${REPO_DIR}/flake.nix).nixConfig.extra-trusted-public-keys
  )
")

UPSTREAM_ARGS=()
for key in cache.nixos.org-1 "${CACHIX_KEYS[@]}"; do
  echo "    - $key"
  UPSTREAM_ARGS+=(--upstream-cache-key-name "$key")
done

echo "==> Making cache public, filtering out paths already on those upstreams"
attic cache configure "$CACHE_NAME" --public "${UPSTREAM_ARGS[@]}"

echo "==> Done. Cache info:"
attic cache info "$CACHE_NAME"

echo
echo "==> Generate push-only client tokens (enter q to stop)"
while true; do
  read -rp "Client name: " CLIENT_NAME
  if [[ "$CLIENT_NAME" == "q" || "$CLIENT_NAME" == "Q" ]]; then
    break
  fi
  if [[ -z "$CLIENT_NAME" ]]; then
    continue
  fi

  CLIENT_TOKEN=$(atticd-atticadm make-token --sub "$CLIENT_NAME" --validity '10 years' --push "$CACHE_NAME")

  echo
  echo "On $CLIENT_NAME, run:"
  echo "  sudo attic login server $SERVER_URL $CLIENT_TOKEN"
  echo
done
