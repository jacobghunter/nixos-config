{ config, pkgs, inputs, ... }:

{
  modules.wayle.showBattery = false;

  home.packages = with pkgs; [
  ];
}

