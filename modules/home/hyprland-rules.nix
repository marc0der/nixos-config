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
    wayland.windowManager.hyprland.settings.windowrulev2 = [
      "tile, class:^(Brave-browser)$"
      "tile, class:^(Chromium)$"
      "float, class:^(org.pulseaudio.pavucontrol)$"
      "float, class:^(.blueman-manager-wrapped)$"
      "float, class:^(nm-connection-editor)$"
      "float, class:^(org.gnome.Calculator)$"
      "float, class:^(qalculate-gtk)$"
      "float, class:^(xdg-desktop-portal-gtk)$"
      "float, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"
      "move 69.5% 4%, title:^(Picture-in-Picture)$"
      "suppressevent maximize, class:.*"
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
    ];
  };
}
