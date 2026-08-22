_: {
  # LAN-only - not port-forwarded past the router.
  networking.firewall.allowedTCPPorts = [ 8081 ];

  services.atticd = {
    enable = true;

    # Replace with absolute path to your environment file
    environmentFile = "/etc/atticd.env";

    settings = {
      listen = "[::]:8081";

      # Required for production use - without this, the substituter URL
      # handed back to clients is synthesized from whatever Host header
      # the request happened to carry. Must be the IP, not the .local
      # hostname - the attic CLI reads this value from cache-config
      # responses and uses it for all follow-up requests (push,
      # get-missing-paths, etc), and its Rust HTTP client can't resolve
      # mDNS names even though nix's own substituter fetches (libcurl) can.
      api-endpoint = "http://192.168.1.167:8081/";
      # Both forms in allowed-hosts: nix's substituter fetches can still
      # arrive with the .local Host header, but the attic CLI now always
      # connects via IP.
      allowed-hosts = [
        "nixos-server.local:8081"
        "192.168.1.167:8081"
      ];

      garbage-collection = {
        # Local disk storage, not S3 - cap growth instead of keeping
        # every pushed path forever.
        default-retention-period = "3 months";
      };

      jwt = { };

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };
}
