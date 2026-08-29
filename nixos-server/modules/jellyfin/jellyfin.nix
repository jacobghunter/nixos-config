{
  pkgs,
  ...
}:
{
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-ocl
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      intel-compute-runtime-legacy1
    ];
  };

  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jellyfin";
  };

  systemd.tmpfiles.rules = [
    "z /var/lib/jellyfin 0750 jellyfin jellyfin -"
    "z /var/lib/jellyfin/root 0750 jellyfin jellyfin -"
    "z /var/lib/jellyfin/root/default 0750 jellyfin jellyfin -"
  ];
}
