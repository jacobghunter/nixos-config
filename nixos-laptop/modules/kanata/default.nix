{ config, pkgs, ... }:

let
  customKanata = pkgs.kanata.overrideAttrs (oldAttrs: rec {
    version = "1.12.0-prerelease-2";
    src = pkgs.fetchFromGitHub {
      owner = "jtroo";
      repo = "kanata";
      rev = "v${version}";
      hash = "sha256-bNUlQBsyGxCu3GHP+qgrYLikLagXxzLjjuZFZFi7Vzk=";
    };
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (
      pkgs.lib.const {
        name = "kanata-vendor.tar.gz";
        inherit src;
        # Updated to the hash Nix is expecting ("got") from your build logs
        outputHash = "sha256-da7kmSvm+z6C+RPqEBEY9PNWxrAEQ8h/ZGDvS9WJ1J8=";
      }
    );
  });
in
{
  hardware.uinput.enable = true;

  boot.kernelModules = [ "uinput" ];

  services.kanata = {
    enable = true;
    # Explicitly hook up the newly scoped custom package
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
}
