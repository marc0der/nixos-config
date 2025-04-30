# Pywal configuration module
{
  config,
  pkgs,
  lib,
  ...
}:

let
  apply-pywal-script = pkgs.writeShellScriptBin "apply-pywal-theme" (
    builtins.readFile ./scripts/apply-pywal-theme.sh
  );
in
{
  # This module manages pywal templates and configuration

  # Add the script to apply pywal theme
  home.packages = [
    apply-pywal-script
  ];

  # Create symlinks to all templates
  home.file = {
    # Pywal templates
    ".config/wal/templates/colors-dunst".source = ./templates/colors-dunst;
    ".config/wal/templates/colors-swaylock.conf".source = ./templates/colors-swaylock.conf;
    ".config/wal/templates/colors-waybar.css".source = ./templates/colors-waybar.css;
    ".config/wal/templates/colors-wlogout.css".source = ./templates/colors-wlogout.css;
  };

  # Add an activation script to run pywal when home-manager is activated
  home.activation.applyPywalTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Applying pywal theme to current wallpaper..."
    # Make sure PATH includes the profile bin directory
    export PATH=$PATH:$HOME/.nix-profile/bin:/run/current-system/sw/bin
    ${apply-pywal-script}/bin/apply-pywal-theme
  '';
}
