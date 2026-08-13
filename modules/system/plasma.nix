# KDE Plasma Desktop Environment Module
#
# This module provides KDE Plasma 6 as a display-manager-selectable
# session, alongside Sway/Hyprland on the same host.
#
# Options:
#   local.programs.plasma-desktop.enable - Enable Plasma desktop environment
#
# Example usage:
#   local.programs.plasma-desktop.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.local.programs.plasma-desktop = {
    enable = mkEnableOption "KDE Plasma desktop environment";
  };

  config = mkIf config.local.programs.plasma-desktop.enable {
    services.desktopManager.plasma6.enable = true;
  };
}
