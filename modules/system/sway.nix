# Sway Desktop Environment Module
#
# This module provides Sway window manager configuration including
# XWayland support and GTK wrapper features.
#
# Options:
#   programs.sway-desktop.enable - Enable Sway desktop environment
#
# Example usage:
#   programs.sway-desktop.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.programs.sway-desktop = {
    enable = mkEnableOption "Sway desktop environment";
  };

  config = mkIf config.programs.sway-desktop.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    programs.xwayland.enable = true;
  };
}
