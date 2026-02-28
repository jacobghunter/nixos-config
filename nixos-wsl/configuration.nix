{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../nixos-shared/system.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "jacob";

  # To set up serial port on wsl:
  # winget install usbipd
  # usbipd list
  # usbipd bind --busid <id>
  # usbipd attach --wsl --busid <id>
  system.activationScripts.modprobeSymlink = ''
    # The -f flag ensures this command works even if the link already exists
    ln -sf ${pkgs.kmod}/bin/modprobe /usr/bin/modprobe
  '';

  networking.hostName = "nixos-wsl";

  users.users.jacob.shell = pkgs.zsh;

  system.stateVersion = "24.11";
}
