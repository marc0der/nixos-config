# XDG Desktop Portal configuration for Plasma
#
# This module configures xdg-desktop-portal with Plasma-specific settings.
# It enables screen capture and screenshot functionality through the KDE portal,
# and routes the Secret interface to the kwallet portal.
#
# Options:
#   local.xdg-portal-plasma.enable - Enable XDG portal for Plasma
#
# Example usage:
#   local.xdg-portal-plasma.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.xdg-portal-plasma;
in
{
  options.local.xdg-portal-plasma = {
    enable = lib.mkEnableOption "XDG desktop portal for Plasma";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.kdePackages.xdg-desktop-portal-kde
        pkgs.kdePackages.kwallet
      ];
      config = {
        kde = {
          default = [ "kde" ];
          "org.freedesktop.impl.portal.ScreenCast" = "kde";
          "org.freedesktop.impl.portal.Screenshot" = "kde";
          "org.freedesktop.impl.portal.Secret" = "kwallet";
        };
      };
    };
  };
}
