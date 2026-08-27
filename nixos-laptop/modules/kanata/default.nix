{ pkgs, ... }:

let
  version = "1.12.0-prerelease-2";

  src = pkgs.fetchFromGitHub {
    owner = "jtroo";
    repo = "kanata";
    rev = "v${version}";
    hash = "sha256-bNUlQBsyGxCu3GHP+qgrYLikLagXxzLjjuZFZFi7Vzk=";
  };

  customKanata = pkgs.kanata.overrideAttrs (_oldAttrs: {
    inherit version src;
    doCheck = false;
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      name = "kanata-vendor-${version}.tar.gz";
      hash = "sha256-da7kmSvm+z6C+RPqEBEY9PNWxrAEQ8h/ZGDvS9WJ1J8=";
    };
  });
in
{
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];

  services.kanata = {
    enable = true;
    package = customKanata;

    keyboards = {
      internal = {
        devices = [
          "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
        ];
        configFile = ./kanata.kbd;
      };
    };
  };

  # Explicitly append the necessary hardware groups to Kanata's systemd service
  systemd.services.kanata-internal = {
    serviceConfig = {
      User = "root";
      Group = "root";
      DynamicUser = pkgs.lib.mkForce false; # Disable the restrictive dynamic user isolation
    };
  };
}
