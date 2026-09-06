{ lib, pkgs, ... }:
let
  libraryPath = "/media/storage/books";

  # The upstream module's ExecStartPre hard-fails unless metadata.db already
  # exists at calibreLibrary. Bootstrap an empty Calibre library on first
  # start so a fresh deploy doesn't crash-loop; existing libraries are
  # untouched since calibredb no-ops when metadata.db is already there.
  initLibrary = pkgs.writeShellScript "calibre-web-init-library" ''
    test -f "${libraryPath}/metadata.db" || ${pkgs.calibre}/bin/calibredb list --library-path="${libraryPath}" >/dev/null
  '';
in
{
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

  # Must run before the upstream module's own ExecStartPre, which checks
  # for metadata.db and fails the unit if it's missing.
  systemd.services.calibre-web.serviceConfig.ExecStartPre = lib.mkBefore [ "${initLibrary}" ];
}
