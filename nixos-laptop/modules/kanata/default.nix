{ config, pkgs, ... }:

{
  hardware.uinput.enable = true;

  services.kanata = {
    enable = true;
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
