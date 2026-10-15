# Common Desktop Packages Module
#
# Desktop tools for standalone compositors such as Hyprland: tray applets,
# launcher, bar and portals. Plasma ships its own equivalents. It also overrides
# the blueman autostart entry so Plasma uses bluedevil instead.
#
# Options:
#   local.desktop-common.enable - Enable common desktop packages
#
# Example usage:
#   local.desktop-common.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.local.desktop-common = {
    enable = mkEnableOption "common desktop packages";
  };

  config = mkIf config.local.desktop-common.enable {
    home.packages = with pkgs; [
      blueman
      brightnessctl
      networkmanagerapplet
      pavucontrol
      rofi
      waybar
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ];

    # Blueman autostart: skip Plasma, which runs bluedevil
    xdg.configFile."autostart/blueman.desktop".text =
      builtins.readFile "${pkgs.blueman}/etc/xdg/autostart/blueman.desktop" + "NotShowIn=KDE;\n";
  };
}
