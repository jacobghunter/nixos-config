{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.pihole;
in
{
  options.modules.pihole = {
    enable = lib.mkEnableOption "Pi-hole DNS + ad-blocking";

    interface = lib.mkOption {
      type = lib.types.str;
      description = "Network interface pi-hole should bind DNS to.";
      example = "eth0";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "homelab.me";
      description = "Local domain pi-hole answers for.";
    };

    upstreams = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "1.1.1.1"
        "1.1.1.2"
      ];
      description = "Upstream DNS resolvers.";
    };

    routerIP = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.1";
      description = "Router/gateway IP - used for the dhcp.router setting and the gateway hosts entry.";
    };

    webPasswordHash = lib.mkOption {
      type = lib.types.str;
      description = "Balloon-hashed admin web password for the pi-hole webserver API.";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      # DISABLE separate dnsmasq (Pi-hole provides its own)
      dnsmasq.enable = false;

      # PI-HOLE FTL ENGINE
      pihole-ftl = {
        enable = true;
        # nixpkgs' pinned v6.6.2 segfaults deterministically right after
        # "Database successfully initialized" on aarch64 (confirmed via
        # strace across multiple fresh-database runs - not corruption, not
        # sandboxing, not our config). v6.6.1's changelog mentions fixing
        # "thread-safety issues causing SIGSEGV under concurrent API load",
        # so this looks like a real upstream regression; v6.7 is the next
        # release after 6.6.2 and doesn't reproduce it.
        package = pkgs.pihole-ftl.overrideAttrs (_old: rec {
          version = "6.7";
          src = pkgs.fetchFromGitHub {
            owner = "pi-hole";
            repo = "FTL";
            tag = "v${version}";
            hash = "sha256-vViQ9ZAhajIfCQvOtKjMO2wj8CRt/1h/dzHHFevbbFU=";
          };
        });
        lists = [
          {
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
            type = "block";
            enabled = true;
            description = "Steven Black's HOSTS";
          }
        ];
        openFirewallDNS = true;
        openFirewallDHCP = true;
        openFirewallWebserver = true;

        settings = {
          # DHCP SERVER (Default is OFF - set active=true if you want Pi-hole to be your router's DHCP)
          dhcp = {
            active = false;
            router = cfg.routerIP;
          };

          dns = {
            inherit (cfg) domain;
            inherit (cfg) interface;
            inherit (cfg) upstreams;
          };

          webserver = {
            api.pwhash = cfg.webPasswordHash;
            session.timeout = 43200; # 12 hours
          };
        };
        useDnsmasqConfig = true;
      };

      # PI-HOLE WEB INTERFACE
      pihole-web = {
        enable = true;
        ports = [ 80 ];
      };

      # DISABLE SYSTEMD-RESOLVED STUB (Conflicts with Pi-hole on port 53)
      resolved = {
        enable = true;
        settings."Resolve" = {
          "DNSStubListener" = "no";
          "MulticastDNS" = "no";
        };
      };
    };

    networking.hosts."${cfg.routerIP}" = [
      "gateway.${cfg.domain}"
      "gateway"
    ];

    systemd = {
      # Fix for a benign FTL log warning
      tmpfiles.rules = [
        "f /etc/pihole/versions 0644 pihole pihole - -"
      ];

      services = {
        # FTL hardcodes its PID file to /run/pihole-FTL.pid with no config/CLI
        # override (checked --help and --config), but upstream's unit doesn't
        # give it anywhere writable under /run - ReadWritePaths alone doesn't
        # help since that only controls mount read-only-ness, not real Unix
        # ownership (/run itself stays root:root 755). RuntimeDirectory creates
        # a pihole-owned dir on the host; BindPaths remounts it *as* /run inside
        # just this service's sandbox, so the hardcoded path resolves somewhere
        # it can actually write, without touching the real host /run at all.
        pihole-ftl.serviceConfig = {
          RuntimeDirectory = "pihole-ftl";
          BindPaths = [ "/run/pihole-ftl:/run" ];
        };

        # binutils (addr2line) on PATH so any future crash gets a real symbol
        # backtrace instead of "command not found" - upstream's `path` option
        # can't do this: it sets environment.PATH at normal priority, and the
        # module forces environment.PATH itself via lib.mkForce, so `path`'s
        # contribution silently loses (no eval error, just zero effect -
        # confirmed by an identical output hash with/without it). ExecStart
        # isn't forced upstream though, so override that instead.
        pihole-ftl.serviceConfig.ExecStart = lib.mkForce "${pkgs.writeShellScript "pihole-ftl-start" ''
          export PATH="${pkgs.binutils}/bin:$PATH"
          exec ${lib.getExe config.services.pihole-ftl.package} no-daemon
        ''}";
      };
    };

  };
}
