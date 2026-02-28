{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../../nixos-shared/modules/hyprland/system.nix
  ];
}
