{
  config,
  lib,
  pkgs,
  ...
}:
let
  libraryPath = "/media/storage/books";

  # The upstream module's ExecStartPre hard-fails unless metadata.db already
  # exists at calibreLibrary. Bootstrap an empty Calibre library on first
  # start so a fresh deploy doesn't crash-loop; existing libraries are
  # untouched since calibredb no-ops when metadata.db is already there.
  initLibrary = pkgs.writeShellScript "calibre-web-init-library" ''
    test -f "${libraryPath}/metadata.db" || ${pkgs.calibre}/bin/calibredb list --library-path="${libraryPath}" >/dev/null
  '';

  # Overwrites the default admin/admin123 login on every first-boot migration,
  # so a fresh deploy on a new machine never sits open with the well-known
  # default. This is a werkzeug.security password HASH, not the plaintext
  # (calibre-web checks it via werkzeug's check_password_hash - confirmed in
  # cps/usermanagement.py) - safe to commit, same reasoning as pi-hole's
  # webPasswordHash (nixos-pihole/pi-hole.nix). Generate one with:
  #   nix shell --impure --expr 'let pkgs = import <nixpkgs> {}; in pkgs.python3.withPackages (ps: [ ps.werkzeug ])' \
  #     --command python3 -c "from werkzeug.security import generate_password_hash; from getpass import getpass; print(generate_password_hash(getpass()))"
  adminPasswordHash = "scrypt:32768:8:1$M3QBBAna11z9b2CP$2683b1c4e65dd4b1c6967d2cca2f02be2a061524df85332094592c34b6fa02df0d95d46fa108aa342f79a44afd2854373f8b3277eeebe8bd548b842ac966ac7e";

  cfg = config.services.calibre-web;
  dataDir = if lib.hasPrefix "/" cfg.dataDir then cfg.dataDir else "/var/lib/${cfg.dataDir}";
  appDb = "${dataDir}/app.db";

  # Renaming (not just re-passwording) matters here: it only ever matches the
  # row still named 'admin', so it fires once on first boot and is a no-op
  # forever after - it won't stomp a password you later change via the UI.
  # A double-quoted shell string here would let bash re-expand any '$...'
  # sequence baked into the hash (e.g. treating `$M3QB...` as a variable and
  # `$2` as a positional param, silently dropping both and corrupting the
  # hash) - a quoted heredoc delimiter disables bash expansion entirely so
  # the Nix-interpolated hash reaches sqlite3 byte-for-byte.
  setAdminAccount = pkgs.writeShellScript "calibre-web-set-admin-account" ''
    ${pkgs.sqlite}/bin/sqlite3 "${appDb}" <<'SQL'
    UPDATE user SET name = 'jacob', password = '${adminPasswordHash}' WHERE name = 'admin';
    SQL
  '';
in
{
  assertions = [
    {
      # Structural check, not a string-equality placeholder check - a real
      # werkzeug hash always has '$'-delimited segments (method$salt$hash),
      # so this can't be defeated by a find-replace touching both sides.
      assertion = lib.hasInfix "$" adminPasswordHash;
      message = "nixos-server/modules/calibre-web: set adminPasswordHash to a real werkzeug hash before deploying (see the comment above it for the generator command).";
    }
  ];

  systemd.tmpfiles.rules = [
    "d ${libraryPath} 0750 calibre-web calibre-web -"
  ];

  services.calibre-web = {
    enable = true;
    listen = {
      ip = "0.0.0.0";
      port = 8085;
    };
    openFirewall = true;

    options = {
      calibreLibrary = libraryPath;
      enableBookUploading = true;
      # Full calibre (ebook-convert) for general format conversion, plus
      # kepubify so Kobo Sync serves proper .kepub.epub - real page numbers
      # and reading stats on the Clara BW instead of plain epub rendering.
      enableBookConversion = true;
      enableKepubify = true;
    };
  };

  systemd.services.calibre-web.serviceConfig.ExecStartPre = lib.mkMerge [
    # Must run before the upstream module's own ExecStartPre, which checks
    # for metadata.db and fails the unit if it's missing.
    (lib.mkBefore [ "${initLibrary}" ])
    # Must run after it - that's the step that runs migrations and creates
    # the admin row in the first place.
    (lib.mkAfter [ "${setAdminAccount}" ])
  ];
}
