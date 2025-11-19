# GTK Theme Module
#
# Provides GTK theming configuration with support for dark and light variants.
# Automatically configures GTK theme, icon theme, and session variables based on the selected variant.
#
# Options:
#   gtk-theme.enable - Enable GTK theming (default: true)
#   gtk-theme.variant - Theme variant: "dark" or "light" (default: "dark")
#
# Example usage:
#   gtk-theme.variant = "dark";  # For Materia-dark theme with Papirus-Dark icons
#   gtk-theme.variant = "light"; # For Materia-light theme with Papirus-Light icons

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.gtk-theme;
in
{
  options.gtk-theme = {
    enable = lib.mkEnableOption "GTK theming configuration" // {
      default = true;
    };

    variant = lib.mkOption {
      type = lib.types.enum [
        "dark"
        "light"
      ];
      default = "dark";
      description = "GTK theme variant to use (dark or light)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      materia-theme
      papirus-icon-theme
    ];

    gtk = {
      theme = {
        name = if cfg.variant == "dark" then "Materia-dark" else "Materia-light";
        package = pkgs.materia-theme;
      };

      iconTheme = {
        name = if cfg.variant == "dark" then "Papirus-Dark" else "Papirus-Light";
        package = pkgs.papirus-icon-theme;
      };
    };

    home.sessionVariables = {
      GTK_THEME = if cfg.variant == "dark" then "Materia-dark" else "Materia-light";
    };
  };
}
