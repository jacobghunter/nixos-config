{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.makemkv;
in
{
  options.modules.makemkv = {
    enable = lib.mkEnableOption "jlesage/makemkv container (MakeMKV with a web-based GUI)";

    imageTag = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "Tag of the jlesage/makemkv image to run.";
    };

    webPort = lib.mkOption {
      type = lib.types.port;
      default = 5800;
      description = "Host port for the application's web GUI.";
    };

    vncPort = lib.mkOption {
      type = lib.types.port;
      default = 5900;
      description = "Host port for the application's GUI via VNC.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open webPort/vncPort in the firewall.";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/makemkv/config";
      description = "Host directory bind-mounted to /config - MakeMKV settings, registration key, logs.";
    };

    outputDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/makemkv/output";
      description = "Host directory bind-mounted to /output - where ripped MKV files are written.";
    };

    storageDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional host directory bind-mounted read-only to /storage, e.g. a folder of ISOs to rip from instead of a physical drive.";
    };

    devices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/dev/sr0"
        "/dev/sg0"
      ];
      description = ''
        Device nodes to pass through for optical drive access. Must include
        both the drive's block device (/dev/srN) and its matching SCSI
        generic device (/dev/sgN) - MakeMKV won't detect the drive without
        the latter. Numbering is machine-specific, so set this per-host
        (check with `lsscsi` or `ls /dev/sr* /dev/sg*`).
      '';
    };

    puid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "User ID the application runs as inside the container (must be able to read/write outputDir).";
    };

    pgid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "Group ID the application runs as inside the container.";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = config.time.timeZone or "Etc/UTC";
      description = "Timezone passed to the container.";
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        MAKEMKV_KEY = "T-vwvnrmF87JuRPLYYO8HnIrZR_LCAF7JXs9iJEm10moGpjEgkvmPTsf6Ox4BI@N5rPp";
        AUTO_DISC_RIPPER = "1";
      };
      description = "Extra environment variables passed to the container, e.g. MAKEMKV_KEY, VNC_PASSWORD, AUTO_DISC_RIPPER.";
    };
  };

  config = lib.mkIf cfg.enable {
    # /dev/sgN (SCSI generic) nodes don't exist unless this is loaded - it's
    # not autoloaded by NixOS's default kernel/udev setup.
    boot.kernelModules = [ "sg" ];

    virtualisation = {
      docker.enable = lib.mkDefault true;
      oci-containers.backend = lib.mkDefault "docker";

      oci-containers.containers.makemkv = {
        image = "jlesage/makemkv:${cfg.imageTag}";
        autoStart = true;

        ports = [
          "${toString cfg.webPort}:5800"
          "${toString cfg.vncPort}:5900"
        ];

        volumes = [
          "${cfg.configDir}:/config"
          "${cfg.outputDir}:/output"
        ]
        ++ lib.optional (cfg.storageDir != null) "${cfg.storageDir}:/storage:ro";

        environment = {
          USER_ID = toString cfg.puid;
          GROUP_ID = toString cfg.pgid;
          TZ = cfg.timezone;
        }
        // cfg.extraEnvironment;

        extraOptions = map (dev: "--device=${dev}:${dev}") cfg.devices;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0755 ${toString cfg.puid} ${toString cfg.pgid} -"
      "d ${cfg.outputDir} 0755 ${toString cfg.puid} ${toString cfg.pgid} -"
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.webPort
        cfg.vncPort
      ];
    };
  };
}
