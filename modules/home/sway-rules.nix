# Sway Window Rules Module
#
# Contains all window-specific rules for floating, positioning, sizing, and behavior.
# Migrated from ~/.config/sway/config.d/50-rules-*.conf
#
# Options:
#   sway-rules.enable - Enable window rules (default: false)
#
# Example usage:
#   sway-rules.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.sway-rules = {
    enable = mkEnableOption "Sway window rules";
  };

  config = mkIf config.sway-rules.enable {
    wayland.windowManager.sway.config.window.commands = [
      # Blueman Manager - floating, centered
      {
        criteria = {
          app_id = ".blueman-manager-wrapped";
        };
        command = "floating enable, move position center";
      }

      # Browser windows - mark and inhibit idle when fullscreen
      {
        criteria = {
          class = "Chromium-browser";
        };
        command = "mark Browser";
      }
      {
        criteria = {
          class = "Brave-browser";
        };
        command = "mark Browser";
      }
      {
        criteria = {
          class = "firefox";
        };
        command = "mark Browser";
      }
      {
        criteria = {
          app_id = "Chromium-browser";
        };
        command = "mark Browser";
      }
      {
        criteria = {
          app_id = "brave-browser";
        };
        command = "mark Browser";
      }
      {
        criteria = {
          app_id = "firefox";
        };
        command = "mark Browser";
      }
      {
        criteria = {
          con_mark = "Browser";
        };
        command = "inhibit_idle fullscreen";
      }

      # Firefox screensharing indicator - floating
      {
        criteria = {
          app_id = "firefox";
          title = "Firefox — Sharing Indicator";
        };
        command = "floating enable";
      }

      # Network Manager applications - floating, centered
      {
        criteria = {
          app_id = "nm-connection-editor";
        };
        command = "floating enable, move position center";
      }
      {
        criteria = {
          app_id = "nm-applet";
        };
        command = "floating enable, move position center";
      }

      # PulseAudio volume control - floating, centered
      {
        criteria = {
          app_id = "pavucontrol";
        };
        command = "floating enable, move position center";
      }
      {
        criteria = {
          app_id = "pavucontrol-qt";
        };
        command = "floating enable, move position center";
      }

      # PolicyKit agent - floating, centered
      {
        criteria = {
          app_id = "lxqt-policykit-agent";
        };
        command = "floating enable, move position center";
      }

      # Google Meet (Brave PWA) - floating, sized
      {
        criteria = {
          app_id = "brave-meet.google.com__-Default";
        };
        command = "floating enable, resize set 1400 900, move position center";
      }

      # Zoom (X11) - floating, sized
      {
        criteria = {
          class = "zoom";
        };
        command = "floating enable, resize set 1400 900, move position center";
      }

      # 1Password - floating, sized
      {
        criteria = {
          class = "1Password";
        };
        command = "floating enable, resize set 1200 800, move position center";
      }
      {
        criteria = {
          app_id = "1Password";
        };
        command = "floating enable, resize set 1200 800, move position center";
      }
    ];
  };
}
