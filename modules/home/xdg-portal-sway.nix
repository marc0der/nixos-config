# XDG Desktop Portal configuration for Sway
#
# This module configures xdg-desktop-portal with Sway/wlroots-specific settings.
# It enables screen capture and screenshot functionality through the wlr portal.
#
# Options:
#   xdg-portal-sway.enable - Enable XDG portal for Sway
#
# Example usage:
#   xdg-portal-sway.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.xdg-portal-sway;
in
{
  options.xdg-portal-sway = {
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
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
