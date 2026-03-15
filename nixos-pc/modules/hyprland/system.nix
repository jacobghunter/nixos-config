{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    "${inputs.self}/nixos-shared/modules/hyprland/system.nix"
  ];
}
