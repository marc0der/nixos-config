# Sway Startup Programs Module
#
# Programs launched at Sway startup: notification daemon, network/Bluetooth
# applets, password manager, backup daemon, kanshi output service, session
# environment imports, and the swayidle idle/lock daemon. Mirrors
# `modules/home/hyprland-startup.nix` for the Sway compositor.
#
# Options:
#   local.sway-startup.enable - Enable Sway startup programs (default: false)
#
# Example usage:
#   local.sway-startup.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.local.sway-startup = {
    enable = mkEnableOption "Sway startup programs";
  };

  config = mkIf config.local.sway-startup.enable {
    wayland.windowManager.sway.config.startup = [
      { command = "dunst"; }
      { command = "nm-applet"; }
      { command = "blueman-applet"; }
      { command = "1password --silent"; }
      { command = "flatpak run com.borgbase.Vorta --daemonize"; }
      {
        command = "systemctl --user restart kanshi.service";
        always = true;
      }
      {
        command = "pkill dunst-wrapped";
        always = true;
      }
      { command = "systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP"; }
      { command = "dbus-update-activation-environment WAYLAND_DISPLAY"; }
      # Swayidle - idle timeout and screen locking
      {
        command = ''
          ${pkgs.swayidle}/bin/swayidle -w \
            timeout 1200 '${pkgs.swaylock-effects}/bin/swaylock --clock --indicator --screenshots --effect-scale 0.4 --effect-vignette 0.2:0.5 --effect-blur 4x2 --datestr "%a %e.%m.%Y" --timestr "%k:%M" -f' \
            timeout 1500 'swaymsg "output * power off"' \
            resume 'swaymsg "output * power on"' \
            timeout 300 'pgrep -xu "$USER" swaylock >/dev/null && swaymsg "output * power off"' \
            resume 'pgrep -xu "$USER" swaylock >/dev/null && swaymsg "output * power on"' \
            before-sleep '${pkgs.swaylock-effects}/bin/swaylock --clock --indicator --screenshots --effect-scale 0.4 --effect-vignette 0.2:0.5 --effect-blur 4x2 --datestr "%a %e.%m.%Y" --timestr "%k:%M" -f' \
            lock '${pkgs.swaylock-effects}/bin/swaylock --clock --indicator --screenshots --effect-scale 0.4 --effect-vignette 0.2:0.5 --effect-blur 4x2 --datestr "%a %e.%m.%Y" --timestr "%k:%M" -f' \
            unlock 'pkill -xu "$USER" -SIGUSR1 swaylock'
        '';
      }
    ];
  };
}
