# Session Variables Module
#
# This module provides common session variables shared across all hosts.
# Session variables include environment configuration for editors, Qt/Wayland,
# cursor themes, and other environment-wide settings.
#
# Options:
#   session-variables.enable - Enable common session variables
#   session-variables.extraVariables - Additional host-specific variables
#
# Example usage:
#   session-variables.enable = true;
#   session-variables.extraVariables = {
#     CUSTOM_VAR = "value";
#   };

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.session-variables;
in
{
  options.session-variables = {
    enable = lib.mkEnableOption "common session variables";

    extraVariables = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional host-specific session variables";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      # Editor configuration
      EDITOR = "nvim";

      # Shell configuration
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";

      # Qt/Wayland configuration
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "qt6ct";

      # Cursor configuration
      XCURSOR_SIZE = "24";
      XCURSOR_THEME = "Bibata-Modern-Ice";

      # Wayland configuration
      NIXOS_OZONE_WL = "1";

      # Nix configuration
      NIXPKGS_ALLOW_UNFREE = "1";

      # XDG directories
      XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots";
    }
    // cfg.extraVariables; # Merge host-specific variables
  };
}
