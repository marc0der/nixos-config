# Hyprland Desktop Environment Module
#
# This module provides all Hyprland-specific packages and services for a complete
# Hyprland desktop environment, including the compositor, utilities, and system services.
#
# Options:
#   hyprland-desktop.enable - Enable the Hyprland desktop environment packages and services
#
# Example usage:
#   hyprland-desktop.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hyprland-desktop;
in
{
  options.hyprland-desktop = {
    enable = lib.mkEnableOption "Hyprland desktop environment packages and services";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Hyprland ecosystem
      hyprland
      hyprpaper
      hypridle
      hyprlock
      hyprpolkitagent
      hyprshot

      # Notifications
      swaynotificationcenter

      # System services
      gnome-keyring
    ];

    services = {
      gnome-keyring = {
        enable = true;
        components = [ "secrets" ];
      };
      network-manager-applet.enable = true;
      hypridle.enable = true;
      hyprpaper.enable = true;
    };
  };
}
