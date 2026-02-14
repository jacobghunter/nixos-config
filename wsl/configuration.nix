{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../shared/system.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "jacob";

  networking.hostName = "nixos-wsl";

  users.users.jacob.shell = pkgs.zsh;

  system.stateVersion = "24.11";
}
