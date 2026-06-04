# Sway Window Manager Configuration Module
#
# Core Sway compositor settings: modifier/terminal, fonts, gaps/borders,
# focus/floating behaviour, outputs, inputs, status bar, and pywal client
# colours. Keybindings and modes live in `sway-keybindings.nix`; autostarted
# programs live in `sway-startup.nix`.
#
# Options:
#   local.sway-config.enable - Enable Sway configuration (default: false)
#
# Example usage:
#   local.sway-config.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.local.sway-config = {
    enable = mkEnableOption "Sway window manager configuration";
  };

  config = mkIf config.local.sway-config.enable {
    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      checkConfig = false; # Disable validation since we use pywal runtime variables
      xwayland = true; # Enable XWayland for X11 app compatibility

      # Load pywal colors FIRST before any config
      extraConfigEarly = ''
        include "$HOME/.cache/wal/colors-sway"
      '';

      config = {
        modifier = "Mod4";
        terminal = "ghostty";

        # Font configuration
        fonts = {
          names = [ "JetBrainsMono NF" ];
          size = 9.0;
        };

        # Gaps and borders
        gaps = {
          inner = 2;
          outer = 2;
          smartBorders = "on";
          smartGaps = true;
        };

        window = {
          border = 2;
        };

        # Focus behavior
        focus = {
          followMouse = false;
        };

        # Floating modifier
        floating = {
          modifier = "Mod4";
        };

        # Output configuration
        output = {
          "eDP-1" = {
            scale = "1.4";
          };
          "DP-1" = {
            scale = "1.0";
            subpixel = "none";
          };
        };

        # Input configuration
        input = {
          "1267:12981:ELAN06D4:00_04F3:32B5_Touchpad" = {
            dwt = "enabled";
            tap = "enabled";
            natural_scroll = "enabled";
            middle_emulation = "enabled";
          };
          "2:10:TPPS/2_Elan_TrackPoint" = {
            natural_scroll = "enabled";
          };
          "1133:45110:Pebble_M350s_Mouse" = {
            dwt = "enabled";
            natural_scroll = "enabled";
          };
          "*" = {
            xkb_layout = "gbx";
          };
        };

        # Waybar status bar configuration
        bars = [
          {
            command = "${pkgs.waybar}/bin/waybar";
            position = "bottom";
          }
        ];
      };

      # Additional config: pywal colors, wallpaper, and config.d includes
      extraConfig = ''
        # Wallpaper (using pywal variable)
        output * bg $wallpaper fill

        # Colors (using pywal variables)
        client.focused           $color1       $color2      $color0      $color3      $color1
        client.focused_inactive  $background   $background  $foreground  $foreground  $background
        client.unfocused         $background   $background  $foreground  $foreground  $background
        client.urgent            $color1       $background  $foreground  $color1      $color1
        client.placeholder       $color8       $background  $foreground  $color8      $color8
        client.background        $background
      '';
    };
  };
}
