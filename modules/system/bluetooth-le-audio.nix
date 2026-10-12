# Bluetooth LE Audio
#
# LE Audio (BAP, LC3, CSIP) for hearing aids and LE Audio earbuds.
#
# Options:
#   local.bluetooth-le-audio.enable - Enable Bluetooth LE Audio
#
# Example usage:
#   local.bluetooth-le-audio.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.local.bluetooth-le-audio;
in
{
  options.local.bluetooth-le-audio = {
    enable = lib.mkEnableOption "Bluetooth LE Audio (BAP, LC3, CSIP)";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.settings.General = {
      Experimental = true;
      KernelExperimental = true;
    };
    hardware.bluetooth.disabledPlugins = [ "asha" ];

    services.pipewire.wireplumber.extraConfig."11-bluez-le-audio" = {
      "monitor.bluez.properties" = {
        "bluez5.roles" = [ "bap_source" ];
        "bluez5.codecs" = [ "lc3" ];
      };
      "monitor.bluez.rules" = [
        {
          matches = [ { "device.name" = "~bluez_card.*"; } ];
          actions.update-props."bluez5.bap.preset" = "24_2_1";
        }
      ];
    };
  };
}
