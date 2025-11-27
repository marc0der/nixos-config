# Hyprland Extras Module
#
# Provides additional Hyprland ecosystem services including hypridle (idle management),
# hyprlock (lock screen), and hyprpaper (wallpaper).
#
# Options:
#   hyprland-extras.enable - Enable Hyprland extra services
#
# Example usage:
#   hyprland-extras.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.hyprland-extras = {
    enable = mkEnableOption "Hyprland extra services (hypridle, hyprlock, hyprpaper)";
  };

  config = mkIf config.hyprland-extras.enable {
    # Hypridle configuration
    services.hypridle = {
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 600;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    # Hyprlock configuration
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          ignore_empty_input = true;
        };

        background = [
          {
            monitor = "";
            path = "$HOME/.wallpaper.jpg";
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "300, 75";
            outline_thickness = 3;
            dots_size = 0.33;
            dots_spacing = 0.15;
            dots_center = true;
            dots_rounding = -1;
            outer_color = "rgb(151515)";
            inner_color = "rgb(FFFFFF)";
            font_color = "rgb(10, 10, 10)";
            fade_on_empty = true;
            fade_timeout = 1000;
            placeholder_text = "<i>Input Password...</i>";
            hide_input = false;
            rounding = -1;
            check_color = "rgb(204, 136, 34)";
            fail_color = "rgb(204, 34, 34)";
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            fail_transition = 300;
            capslock_color = -1;
            numlock_color = -1;
            bothlock_color = -1;
            invert_numlock = false;
            swap_font_color = false;
            position = "0, -20";
            halign = "center";
            valign = "center";
            shadow_passes = 10;
            shadow_size = 20;
            shadow_color = "rgb(0,0,0)";
            shadow_boost = 1.6;
          }
        ];

        label = [
          {
            monitor = "";
            text = "cmd[update:1000] echo \"$TIME\"";
            color = "rgba(200, 200, 200, 1.0)";
            font_size = 55;
            font_family = "Fira Semibold";
            position = "-100, 50";
            halign = "right";
            valign = "bottom";
            shadow_passes = 5;
            shadow_size = 10;
          }
          {
            monitor = "";
            text = "$USER";
            color = "rgba(200, 200, 200, 1.0)";
            font_size = 20;
            font_family = "Fira Semibold";
            position = "-100, 140";
            halign = "right";
            valign = "bottom";
            shadow_passes = 5;
            shadow_size = 10;
          }
        ];

        image = [
          {
            monitor = "";
            size = 280;
            rounding = 40;
            border_size = 4;
            border_color = "rgb(221, 221, 221)";
            rotate = 0;
            reload_time = -1;
            position = "0, 200";
            halign = "center";
            valign = "center";
            shadow_passes = 10;
            shadow_size = 20;
            shadow_color = "rgb(0,0,0)";
            shadow_boost = 1.6;
          }
        ];
      };
    };

    # Hyprpaper configuration
    services.hyprpaper = {
      settings = {
        preload = [ "/home/marco/.wallpaper.jpg" ];
        wallpaper = [
          "eDP-1,/home/marco/.wallpaper.jpg"
          ",/home/marco/.wallpaper.jpg"
        ];
      };
    };
  };
}
