# Common Desktop Packages Module
#
# This module provides common desktop environment packages used by both hosts
# regardless of their specific compositor (Hyprland/Sway).
#
# Options:
#   desktop-common.enable - Enable common desktop packages
#
# Example usage:
#   desktop-common.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.desktop-common = {
    enable = mkEnableOption "common desktop packages";
  };

  config = mkIf config.desktop-common.enable {
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
