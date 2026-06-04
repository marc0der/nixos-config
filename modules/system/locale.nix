# Locale, time zone, and console keymap
#
# Sets the system locale to en_GB.UTF-8 (with all LC_* overrides), the time
# zone to Europe/London, and the console keymap to "uk". Single module so a
# host that wants any of these gets the consistent bundle.
#
# Options:
#   local.locale-en-gb.enable - Enable en_GB locale + Europe/London + uk console
#
# Example usage:
#   local.locale-en-gb.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.local.locale-en-gb;
in
{
  options.local.locale-en-gb = {
    enable = lib.mkEnableOption "en_GB locale, Europe/London time zone, uk console";
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = "Europe/London";

    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };

    console.keyMap = "uk";
  };
}
