# XDG Desktop Portal configuration for Sway
#
# This module configures xdg-desktop-portal with Sway/wlroots-specific settings.
# It enables screen capture and screenshot functionality through the wlr portal.
# The wlr backend unit is bound to sway-session.target rather than
# graphical-session.target, so it never starts in a non-wlroots session such as
# Plasma, where it can only fail to connect to a display.
#
# Options:
#   local.xdg-portal-sway.enable - Enable XDG portal for Sway
#
# Example usage:
#   local.xdg-portal-sway.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.xdg-portal-sway;
in
{
  options.local.xdg-portal-sway = {
    enable = lib.mkEnableOption "XDG desktop portal for Sway";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      xdg-desktop-portal-wlr
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config = {
        common = {
          default = "gtk";
        };
        sway = {
          default = [
            "gtk"
            "wlr"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
        };
      };
    };

    systemd.user.services.xdg-desktop-portal-wlr = {
      Unit = {
        Description = "xdg-desktop-portal-wlr";
        PartOf = [ "sway-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };
  };
}
