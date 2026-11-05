{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.tailscale;
  advertising = cfg.advertiseRoutes != [ ] || cfg.exitNode;
in
{
  options.modules.tailscale = {
    enable = lib.mkEnableOption "Tailscale mesh VPN (remote access to the home network)";

    advertiseRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "192.168.1.0/24" ];
      description = ''
        Subnets to advertise to the tailnet, making this machine a subnet
        router so devices that can't run Tailscale (router, printers, the
        pi-hole) are reachable remotely. Each route must also be approved
        once in the Tailscale admin console.
      '';
    };

    exitNode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Offer this machine as an exit node (route all of a client's traffic through home). Must be approved in the admin console.";
    };

    acceptRoutes = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Use subnet routes advertised by other nodes. Leave off on machines
        that live on the home LAN anyway - only useful for ones that roam
        (e.g. the laptop).
      '';
    };

    trustInterface = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Treat tailscale0 as trusted in the firewall, so every local service is reachable over the tailnet without opening its port on the LAN.";
    };

    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Optional file holding a Tailscale auth key, for joining the tailnet
        unattended. When null, run `sudo tailscale up` once by hand and log
        in through the printed URL - the node key then lives in
        /var/lib/tailscale and survives rebuilds.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      # Opens UDP 41641 for direct (non-relayed) connections - not required,
      # Tailscale falls back to NAT traversal / DERP relays without it.
      openFirewall = true;
      # "server" turns on IP forwarding for subnet routing/exit node;
      # "client" loosens reverse-path filtering so accepted routes work.
      useRoutingFeatures = if advertising then "both" else "client";
      inherit (cfg) authKeyFile;

      # Applied with `tailscale set` on every service start, so these take
      # effect even when the node was logged in manually with `tailscale up`.
      extraSetFlags =
        lib.optional (
          cfg.advertiseRoutes != [ ]
        ) "--advertise-routes=${lib.concatStringsSep "," cfg.advertiseRoutes}"
        ++ lib.optional cfg.exitNode "--advertise-exit-node"
        ++ lib.optional cfg.acceptRoutes "--accept-routes";
    };

    networking.firewall.trustedInterfaces = lib.mkIf cfg.trustInterface [ "tailscale0" ];
  };
}
