# XDG Desktop Portal configuration for Hyprland
#
# This module configures xdg-desktop-portal with Hyprland-specific settings.
# It enables screen capture and screenshot functionality through the Hyprland portal.
#
# Options:
#   xdg-portal-hyprland.enable - Enable XDG portal for Hyprland
#
# Example usage:
#   xdg-portal-hyprland.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.xdg-portal-hyprland;
in
{
  options.xdg-portal-hyprland = {
    enable = lib.mkEnableOption "XDG desktop portal for Hyprland";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      xdg-desktop-portal-hyprland
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
      config = {
        common = {
          default = "gtk";
        };
        hyprland = {
          default = [
            "gtk"
            "hyprland"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
          "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        };
      };
    };
  };
}
