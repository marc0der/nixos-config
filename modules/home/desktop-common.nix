# Common Desktop Packages Module
#
# This module provides common desktop environment packages used by both hosts
# regardless of their specific compositor (Hyprland/Sway).
#
# Options:
#   local.desktop-common.enable - Enable common desktop packages
#
# Example usage:
#   local.desktop-common.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.local.desktop-common = {
    enable = mkEnableOption "common desktop packages";
  };

  config = mkIf config.local.desktop-common.enable {
    home.packages = with pkgs; [
      blueman
      brightnessctl
      desktop-file-utils
      networkmanagerapplet
      pavucontrol
      playerctl
      wl-clipboard
      rofi
      waybar
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ];
  };
}
