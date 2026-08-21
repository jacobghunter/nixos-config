{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.packages = with pkgs; [
    powerstat
    upower
    screen
  ];

  home.shellAliases = {
    earbuds-on = "bluetoothctl unblock DC:C4:9C:DF:EB:C0 && bluetoothctl connect DC:C4:9C:DF:EB:C0";
    earbuds-off = "bluetoothctl disconnect DC:C4:9C:DF:EB:C0 && bluetoothctl block DC:C4:9C:DF:EB:C0";
  };
}
