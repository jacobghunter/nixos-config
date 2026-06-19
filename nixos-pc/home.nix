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

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
  };

  xdg.configFile."wireplumber/wireplumber.conf.d/52-disable-devices.conf".text = ''
    monitor.alsa.rules = [
      # 1. Disable Samson Q2U headphone/output node (leaves mic input active)
      {
        matches = [
          {
            node.name = "alsa_output.usb-Samson_Technologies_Samson_Q2U_Microphone-00.analog-stereo"
          }
        ]
        actions = {
          update-props = {
            node.disabled = true
          }
        }
      }
      # 2. Disable motherboard built-in audio controller (Ryzen HD Audio)
      {
        matches = [
          {
            device.name = "alsa_card.pci-0000_10_00.6"
          }
        ]
        actions = {
          update-props = {
            device.disabled = true
          }
        }
      }
      # 3. Disable GPU Navi 31 HDMI/DP Audio Controller
      {
        matches = [
          {
            device.name = "alsa_card.pci-0000_03_00.1"
          }
        ]
        actions = {
          update-props = {
            device.disabled = true
          }
        }
      }
      # 4. Disable GPU Radeon High Definition Audio Controller
      {
        matches = [
          {
            device.name = "alsa_card.pci-0000_10_00.1"
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
