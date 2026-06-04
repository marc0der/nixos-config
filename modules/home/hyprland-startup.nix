# Hyprland Startup Programs Module
#
# Programs launched once when Hyprland starts (`exec-once`): 1Password, Vorta,
# pywal colour application, and cliphist clipboard watchers. Mirrors
# `modules/home/sway-startup.nix` for the Hyprland compositor.
#
# Options:
#   local.hyprland-startup.enable - Enable Hyprland startup programs (default: false)
#
# Example usage:
#   local.hyprland-startup.enable = true;

{
  config,
  lib,
  ...
}:

with lib;

{
  options.local.hyprland-startup = {
    enable = mkEnableOption "Hyprland startup programs";
  };

  config = mkIf config.local.hyprland-startup.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      "1password --silent"
      "flatpak run com.borgbase.Vorta --daemonize"
      "wal -i $(hyprctl hyprpaper listactive | head -n1 | awk '{print $NF}') -b \"##0c0e10\""
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
    ];
  };
}
