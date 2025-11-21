# Sway Desktop Environment Module
#
# Provides Sway-specific packages and configuration.
#
# Options:
#   sway-desktop.enable - Enable Sway desktop packages
#
# Example usage:
#   sway-desktop.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.sway-desktop = {
    enable = mkEnableOption "Sway desktop environment packages";
  };

  config = mkIf config.sway-desktop.enable {
    home.packages = with pkgs; [
      alacritty
      dunst
      sway
      sway-contrib.grimshot
      swaylock-effects
    ];
  };
}
