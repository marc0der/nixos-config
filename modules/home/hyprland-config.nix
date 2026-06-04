# Hyprland Window Manager Configuration Module
#
# Core Hyprland compositor settings: monitors, general/decoration/animation
# rules, layouts, input/device tweaks, and pywal border colours. Keybindings
# live in `hyprland-keybindings.nix`, autostarted programs in
# `hyprland-startup.nix`, and idle/lock/wallpaper services in
# `hyprland-extras.nix`.
#
# Options:
#   local.hyprland-config.enable - Enable Hyprland configuration
#
# Example usage:
#   local.hyprland-config.enable = true;

{
  config,
  lib,
  ...
}:

with lib;

{
  options.local.hyprland-config = {
    enable = mkEnableOption "Hyprland window manager configuration";
  };

  config = mkIf config.local.hyprland-config.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      settings = {
        # Monitor configuration
        monitor = [
          "desc:Dell Inc. DELL U3219Q 38RYXV2,preferred,0x0,1"
          "desc:Samsung Display Corp. 0x419F,preferred,970x2160,1.5"
          ",preferred,auto,1"
        ];

        # XWayland settings
        xwayland = {
          force_zero_scaling = true;
        };

        # Environment variables
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          resize_on_border = true;
          allow_tearing = false;
          layout = "dwindle";
        };

        # Decoration settings
        decoration = {
          rounding = 5;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };

        # Animations
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        # Dwindle layout
        dwindle = {
          preserve_split = true;
        };

        # Master layout
        master = {
          new_status = "master";
        };

        # Misc settings
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };

        # Input settings
        input = {
          kb_layout = "gbx";
          follow_mouse = 1;
          sensitivity = 0;
          touchpad = {
            natural_scroll = true;
          };
        };

        # Per-device settings
        device = [
          {
            name = "tpps/2-elan-trackpoint";
            natural_scroll = true;
          }
          {
            name = "pebble-m350s-mouse";
            natural_scroll = true;
          }
        ];

      };

      # Pywal border colours (resize submap lives in `hyprland-keybindings.nix`)
      extraConfig = ''
        # Source pywal colors FIRST
        source = ~/.cache/wal/colors-hyprland.conf

        # Apply pywal colors to borders (must be after source)
        general {
          col.active_border = $color6 $color4 45deg
          col.inactive_border = $color3
        }
      '';
    };
  };
}
