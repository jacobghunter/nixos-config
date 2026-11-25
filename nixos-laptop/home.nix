{
  pkgs,
  ...
}:

{
  modules.noctalia.hostConfig = ./modules/noctalia/config.toml;

  home.packages = with pkgs; [
    powerstat
    upower
    screen
  ];

  home.shellAliases = {
    earbuds-on = "bluetoothctl unblock DC:C4:9C:DF:EB:C0 && bluetoothctl connect DC:C4:9C:DF:EB:C0";
    earbuds-off = "bluetoothctl disconnect DC:C4:9C:DF:EB:C0 && bluetoothctl block DC:C4:9C:DF:EB:C0";
    # Server's LAN IP rather than the nixos-server alias (.local is mDNS,
    # LAN-only); the IP works at home and away via its Tailscale subnet route.
    wake-pc = "ssh jacob@192.168.1.167 wake-pc";
  };
}
