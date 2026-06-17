{
  config,
  pkgs,
  inputs,
  ...
}:

{
  modules.wayle.showBattery = false;
  modules.btop.package = pkgs.btop-rocm;

  home.packages = with pkgs; [
    nvtopPackages.amd
  ];

  xdg.configFile."wireplumber/wireplumber.conf.d/52-disable-devices.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          {
            node.name = "alsa_output.pci-0000_00_1f.3.hdmi-stereo"
          }
        ]
        actions = {
          update-props = {
            node.disabled = true
          }
        }
      }
      {
        matches = [
          {
            device.name = "alsa_card.pci-0000_08_00.1"
          }
        ]
        actions = {
          update-props = {
            device.disabled = true
          }
        }
      }
    ]
  '';
}
