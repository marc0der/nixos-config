# Common Wayland configuration module
#
# This module provides common configuration for Wayland compositors (Hyprland and Sway).
# It includes shared environment variables, XDG desktop portal base configuration,
# and common display manager settings.
#
# Options:
#   wayland.enable - Enable common Wayland configuration (default: false)
#
# Example usage:
#   wayland.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.wayland = {
    enable = mkEnableOption "common Wayland configuration for compositors";
  };

  config = mkIf config.wayland.enable {
    # XDG desktop portal base configuration
    # Note: Compositor-specific portals (hyprland/wlr) are configured in their respective modules
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };

    # Common environment variables for Wayland
    environment.sessionVariables = {
      # Qt applications should prefer Wayland, fall back to X11
      QT_QPA_PLATFORM = "wayland;xcb";
      # Use qt6ct for Qt theming
      QT_QPA_PLATFORMTHEME = "qt6ct";
      # Ensure SDL2 uses Wayland when available
      SDL_VIDEODRIVER = "wayland";
      # Clutter backend
      CLUTTER_BACKEND = "wayland";
    };

    # Display manager (SDDM) is already configured in base configuration.nix
    # Both compositors use the same display manager, so no additional config needed here
  };
}
