{ lib, inputs, ... }:

{
  imports = [
    "${inputs.self}/nixos-shared/modules/hyprland/home.nix"
  ];

  modules.hyprland.enableWallpaperEngine = true;
  modules.hyprland.wallpaperEngineMap = {
    "DP-1" = "2557395646"; # First monitor
    "HDMI-A-1" = "2286109162"; # Second monitor
  };

  modules.hyprland.idleTimeout = 600; # 10 minutes
  modules.hyprland.dpmsTimeout = 900; # 15 minutes

  xdg.configFile."hypr/pc.lua".source = ./pc.lua;

  # Append the pcall requirement directly to the main lua file
  xdg.configFile."hypr/hyprland.lua".text = lib.mkAfter ''
    -- PC configuration
    require("pc")
  '';
}
