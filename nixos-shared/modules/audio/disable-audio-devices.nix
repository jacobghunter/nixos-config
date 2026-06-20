{ config, lib, ... }:
let
  cfg = config.modules.audioDeviceDisable;

  mkNodeRule = name: {
    matches = [ { node.name = name; } ];
    actions.update-props.node.disabled = true;
  };

  mkDeviceRule = name: {
    matches = [ { device.name = name; } ];
    actions.update-props.device.disabled = true;
  };
in
{
  options.modules.audioDeviceDisable = {
    nodeNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "alsa node.name values to disable (e.g. a single output/input on a multi-port device).";
      example = [ "alsa_output.usb-Samson_Technologies_Samson_Q2U_Microphone-00.analog-stereo" ];
    };

    deviceNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "alsa device.name values to disable (disables the whole card/controller).";
      example = [ "alsa_card.pci-0000_10_00.6" ];
    };
  };

  config = lib.mkIf (cfg.nodeNames != [ ] || cfg.deviceNames != [ ]) {
    xdg.configFile."wireplumber/wireplumber.conf.d/52-disable-devices.conf".text =
      let
        rules = (map mkNodeRule cfg.nodeNames) ++ (map mkDeviceRule cfg.deviceNames);
      in
      ''
        monitor.alsa.rules = ${builtins.toJSON rules}
      '';
  };
}
