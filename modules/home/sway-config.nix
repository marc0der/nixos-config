# Sway Window Manager Configuration Module
#
# Migrated from ~/.config/sway/config with pywal integration preserved.
# Config.d includes are maintained for incremental migration.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.sway-config = {
    enable = mkEnableOption "Sway window manager configuration";
  };

  config = mkIf config.sway-config.enable {
    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;

      # Load pywal colors FIRST before any config
      extraConfigEarly = ''
        include "$HOME/.cache/wal/colors-sway"
      '';

      config = {
        modifier = "Mod4";
        terminal = "alacritty";

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
          "*" = {
            bg = "$wallpaper fill";
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
            xkb_layout = "gb";
          };
        };

        # Keybindings
        keybindings =
          let
            mod = config.wayland.windowManager.sway.config.modifier;
          in
          {
            # Basic bindings
            "${mod}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";
            "${mod}+Shift+Return" = "exec brave --enable-features=UseOzonePlatform --ozone-platform=wayland";
            "${mod}+Shift+n" = "exec nautilus";
            "${mod}+Shift+q" = "kill";
            "${mod}+Space" = "exec rofi -terminal 'alacritty' -show combi -combi-modes drun#run -modes combi";
            "${mod}+Shift+v" = "exec mpv --really-quiet --speed=0.5 --vo=wlshm --stop-screensaver --fullscreen --no-audio --shuffle --loop-playlist=inf $HOME/Videos/MovingWallpaper/";

            # Lock screen
            "${mod}+Escape" = "exec swaylock --clock --indicator --screenshots --effect-scale 0.4 --effect-vignette 0.2:0.5 --effect-blur 4x2 --datestr '%a %e.%m.%Y' --timestr '%k:%M' -f";

            # Reload and exit
            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+e" = "exec wlogout";

            # Focus movement (vim keys)
            "${mod}+h" = "focus left";
            "${mod}+j" = "focus down";
            "${mod}+k" = "focus up";
            "${mod}+l" = "focus right";

            # Focus movement (arrow keys)
            "${mod}+Left" = "focus left";
            "${mod}+Down" = "focus down";
            "${mod}+Up" = "focus up";
            "${mod}+Right" = "focus right";

            # Move windows (vim keys)
            "${mod}+Shift+h" = "move left";
            "${mod}+Shift+j" = "move down";
            "${mod}+Shift+k" = "move up";
            "${mod}+Shift+l" = "move right";

            # Move windows (arrow keys)
            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Down" = "move down";
            "${mod}+Shift+Up" = "move up";
            "${mod}+Shift+Right" = "move right";

            # Workspace switching
            "${mod}+1" = "workspace number 1";
            "${mod}+2" = "workspace number 2";
            "${mod}+3" = "workspace number 3";
            "${mod}+4" = "workspace number 4";
            "${mod}+5" = "workspace number 5";
            "${mod}+6" = "workspace number 6";
            "${mod}+7" = "workspace number 7";
            "${mod}+8" = "workspace number 8";
            "${mod}+9" = "workspace number 9";
            "${mod}+0" = "workspace number 10";

            # Move to workspace
            "${mod}+Shift+1" = "move container to workspace number 1";
            "${mod}+Shift+2" = "move container to workspace number 2";
            "${mod}+Shift+3" = "move container to workspace number 3";
            "${mod}+Shift+4" = "move container to workspace number 4";
            "${mod}+Shift+5" = "move container to workspace number 5";
            "${mod}+Shift+6" = "move container to workspace number 6";
            "${mod}+Shift+7" = "move container to workspace number 7";
            "${mod}+Shift+8" = "move container to workspace number 8";
            "${mod}+Shift+9" = "move container to workspace number 9";
            "${mod}+Shift+0" = "move container to workspace number 10";

            # Workspace navigation
            "${mod}+Ctrl+l" = "workspace next_on_output";
            "${mod}+Ctrl+h" = "workspace prev_on_output";

            # Layout management
            "${mod}+b" = "splith";
            "${mod}+v" = "splitv";
            "${mod}+t" = "layout toggle stacked tabbed splitv splith";
            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+e" = "layout toggle split";
            "${mod}+f" = "fullscreen";
            "${mod}+Shift+f" = "floating toggle";

            # Scratchpad
            "${mod}+Ctrl+m" = "move scratchpad";
            "${mod}+Ctrl+a" = "scratchpad show";

            # Screenshots
            "${mod}+Shift+p" = "exec grimshot savecopy area";
            "${mod}+Print" = "exec grimshot save active";
            "${mod}+Ctrl+Print" = "exec grimshot save window";
            "${mod}+Shift+Print" = "exec grimshot save area";
            "${mod}+Ctrl+Shift+Print" = "exec grimshot save screen";

            # Resize mode
            "${mod}+r" = "mode resize";
          };

        # Modes
        modes = {
          resize = {
            "h" = "resize shrink width 40px";
            "j" = "resize grow height 40px";
            "k" = "resize shrink height 40px";
            "l" = "resize grow width 40px";
            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };

        # Colors (using pywal variables)
        colors = {
          focused = {
            border = "$color1";
            background = "$color2";
            text = "$color0";
            indicator = "$color3";
            childBorder = "$color1";
          };
          focusedInactive = {
            border = "$background";
            background = "$background";
            text = "$foreground";
            indicator = "$foreground";
            childBorder = "$background";
          };
          unfocused = {
            border = "$background";
            background = "$background";
            text = "$foreground";
            indicator = "$foreground";
            childBorder = "$background";
          };
          urgent = {
            border = "$color1";
            background = "$background";
            text = "$foreground";
            indicator = "$color1";
            childBorder = "$color1";
          };
          placeholder = {
            border = "$color8";
            background = "$background";
            text = "$foreground";
            indicator = "$color8";
            childBorder = "$color8";
          };
        };

        # Startup programs
        startup = [
          { command = "dunst"; }
          { command = "nm-applet"; }
          { command = "blueman-applet"; }
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
        ];
      };

      # Additional config: include existing config.d files for incremental migration
      extraConfig = ''
        include "$HOME/.config/sway/config.d/*.conf"
      '';
    };
  };
}
