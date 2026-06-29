{ lib, inputs, ... }:

{
  imports = [
    "${inputs.self}/nixos-shared/modules/hyprland/home.nix"
  ];

  modules.hyprland.idleTimeout = 150; # 2.5 minutes
  modules.hyprland.dpmsTimeout = 300; # 5 minutes

  xdg.configFile."hypr/laptop.lua".source = ./laptop.lua;

  # Append the pcall requirement directly to the main lua file
  xdg.configFile."hypr/hyprland.lua".text = lib.mkAfter ''
    -- Laptop configuration
    require("laptop")
  '';
}
