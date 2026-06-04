# Sway Desktop Environment Module
#
# This module provides Sway window manager configuration including
# XWayland support and GTK wrapper features.
#
# Options:
#   local.programs.sway-desktop.enable - Enable Sway desktop environment
#
# Example usage:
#   local.programs.sway-desktop.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.local.programs.sway-desktop = {
    enable = mkEnableOption "Sway desktop environment";
  };

  config = mkIf config.local.programs.sway-desktop.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    programs.xwayland.enable = true;
  };
}
