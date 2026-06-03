# Hyprland Window Rules Module
#
# Provides window-specific rules for Hyprland including floating, tiling,
# positioning, and behavior rules for various applications.
#
# Options:
#   hyprland-rules.enable - Enable Hyprland window rules
#
# Example usage:
#   hyprland-rules.enable = true;

{
  config,
  lib,
  ...
}:

with lib;

{
  options.hyprland-rules = {
    enable = mkEnableOption "Hyprland window rules";
  };

  config = mkIf config.hyprland-rules.enable {
    wayland.windowManager.hyprland.settings.windowrule = [
      "tile true, match:class ^(Brave-browser)$"
      "tile true, match:class ^(Chromium)$"
      "float true, match:class ^(org.pulseaudio.pavucontrol)$"
      "float true, match:class ^(.blueman-manager-wrapped)$"
      "float true, match:class ^(nm-connection-editor)$"
      "float true, match:class ^(org.gnome.Calculator)$"
      "float true, match:class ^(qalculate-gtk)$"
      "float true, match:class ^(xdg-desktop-portal-gtk)$"
      "float true, match:title ^(Picture-in-Picture)$"
      "pin true, match:title ^(Picture-in-Picture)$"
      "move 69.5% 4%, match:title ^(Picture-in-Picture)$"
      "suppress_event maximize, match:class .*"
      "no_focus true, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0"
      "no_initial_focus true, match:class ^(jetbrains-idea)$, match:title ^(win.*)$"
    ];
  };
}
