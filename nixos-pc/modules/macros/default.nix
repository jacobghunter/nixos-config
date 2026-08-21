{ pkgs, ... }:

{
  # Wayland/Hyprland has no global mouse-hook API, so detecting a right-click
  # hold means reading raw evdev events; injecting the spammed clicks needs a
  # uinput virtual device. Both happen in clickmacro.py.
  hardware.uinput.enable = true;

  users.users.jacob.extraGroups = [
    "input" # read /dev/input/eventX (the physical mouse)
    "uinput" # write /dev/uinput (the virtual mouse)
  ];

  environment.systemPackages = [
    (pkgs.writers.writePython3Bin "clickmacro" {
      libraries = [ pkgs.python3Packages.evdev ];
    } (builtins.readFile ./clickmacro.py))
  ];
}
