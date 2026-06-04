# Hyprland Desktop Environment Module
#
# This module provides Hyprland window manager configuration including
# hyprlock for screen locking and UWSM session management.
#
# Options:
#   local.programs.hyprland-desktop.enable - Enable Hyprland desktop environment
#
# Example usage:
#   local.programs.hyprland-desktop.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.local.programs.hyprland-desktop = {
    enable = mkEnableOption "Hyprland desktop environment";
  };

  config = mkIf config.local.programs.hyprland-desktop.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    programs.hyprlock.enable = true;

    security.pam.services.hyprlock = { };
  };
}
