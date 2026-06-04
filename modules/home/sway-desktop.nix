# Sway Desktop Environment Module
#
# Provides Sway-specific packages and configuration.
#
# Options:
#   local.sway-desktop.enable - Enable Sway desktop packages
#
# Example usage:
#   local.sway-desktop.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.local.sway-desktop = {
    enable = mkEnableOption "Sway desktop environment packages";
  };

  config = mkIf config.local.sway-desktop.enable {
    home.packages = with pkgs; [
      dunst
      sway-contrib.grimshot
      swaylock-effects
    ];
  };
}
