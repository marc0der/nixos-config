# Keychron K3 Pro udev rules
#
# Grants the `dialout` group read/write access to the Keychron K3 Pro's HID
# interfaces so VIA / QMK firmware tools can talk to the keyboard without
# sudo.
#
# Options:
#   keychron-udev.enable - Install Keychron K3 Pro udev rules
#
# Example usage:
#   keychron-udev.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.keychron-udev;
in
{
  options.keychron-udev = {
    enable = lib.mkEnableOption "Keychron K3 Pro udev rules";
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      # Keychron K3 Pro - specific product ID
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0231", MODE="0664", GROUP="dialout"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0231", MODE="0664", GROUP="dialout"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0231", MODE="0664", GROUP="dialout"
    '';
  };
}
