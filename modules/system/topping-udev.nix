# Topping DX1 II udev rules
#
# Grants the active seat user read/write access to the Topping DX1 II's HID
# interfaces so Chrome's WebHID API can talk to the DAC from
# https://home.toppingaudio.com without sudo.
#
# Installed via services.udev.packages rather than services.udev.extraRules:
# extraRules lands in 99-local.rules, which udev processes after systemd's
# 73-seat-late.rules, so a uaccess tag set there is never acted on. The 60-
# prefix keeps the tag ahead of that consumer.
#
# Options:
#   local.topping-udev.enable - Install Topping DX1 II udev rules
#
# Example usage:
#   local.topping-udev.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.topping-udev;

  rules = pkgs.writeTextFile {
    name = "topping-dx1-udev-rules";
    destination = "/etc/udev/rules.d/60-topping-dx1.rules";
    text = ''
      # Topping DX1 II - WebHID configuration interface
      KERNEL=="hidraw*", ATTRS{idVendor}=="152a", ATTRS{idProduct}=="8750", TAG+="uaccess"
    '';
  };
in
{
  options.local.topping-udev = {
    enable = lib.mkEnableOption "Topping DX1 II udev rules";
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ rules ];
  };
}
