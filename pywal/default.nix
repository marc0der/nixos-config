# Pywal configuration module
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # This module manages pywal templates and configuration

  # Add the script to apply pywal theme
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "apply-pywal-theme" (builtins.readFile ./scripts/apply-pywal-theme.sh))
  ];

  # Create symlinks to all templates
  home.file = {
    # Pywal templates
    ".config/wal/templates/colors-dunst".source = ./templates/colors-dunst;
    ".config/wal/templates/colors-swaylock.conf".source = ./templates/colors-swaylock.conf;
    ".config/wal/templates/colors-waybar.css".source = ./templates/colors-waybar.css;
    ".config/wal/templates/colors-wlogout.css".source = ./templates/colors-wlogout.css;
  };
}
