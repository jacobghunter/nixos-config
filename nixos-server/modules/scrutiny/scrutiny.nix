_: {
  # SMART dashboard + history for the server's drives (http://server.home:8084),
  # surfaced on the homepage. smartd (nixos-server/media-disk.nix) still runs the
  # scheduled self-tests; scrutiny just collects and graphs the results.
  services.scrutiny = {
    enable = true;
    openFirewall = true;
    settings.web.listen.port = 8084;
    collector = {
      enable = true;
      # Default is daily - hourly so a failing drive shows up on the homepage
      # the same day.
      schedule = "hourly";
      # The USB Seagate is found by `smartctl --scan` as -d sat (needs the
      # usb-storage quirk in media-disk.nix), so no device overrides needed.
    };
  };

  # SCRUTINY_NOTIFY_URLS=ntfy://ntfy.sh/<topic> - alerts to the same ntfy topic
  # as smartd (see media-disk.nix). Kept out of the repo since anyone with the
  # topic name can read/post to it.
  systemd.services.scrutiny.serviceConfig.EnvironmentFile = "/etc/ntfy.env";
}
