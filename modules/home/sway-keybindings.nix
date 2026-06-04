# Sway Keybindings Module
#
# All Sway keybindings: navigation, window/workspace management, layout,
# scratchpad, brightness, media control, screenshots, volume, plus the
# `resize` and `passthrough` modes. Mirrors
# `modules/home/hyprland-keybindings.nix` for the Sway compositor.
#
# Options:
#   sway-keybindings.enable - Enable keybindings (default: false)
#   sway-keybindings.brightnessStep - Brightness change step percentage (default: "5")
#   sway-keybindings.volumeStep - Volume change step numeric (default: "5")
#   sway-keybindings.volumeLimit - Maximum volume percentage numeric (default: "100")
#
# Example usage:
#   sway-keybindings.enable = true;
#   sway-keybindings.brightnessStep = "10";

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.sway-keybindings;

  # Brightness notification command (single line for sway config)
  brightnessNotification = ''command -v notify-send >/dev/null && VALUE=$(${pkgs.brightnessctl}/bin/brightnessctl --percentage get) && ${pkgs.libnotify}/bin/notify-send -e -h string:x-canonical-private-synchronous:brightness -h "int:value:$VALUE" -t 800 "Brightness: ''${VALUE}%"'';

  # Volume helper script path
  volumeHelper = "/home/marco/bin/volume-helper";
in
{
  options.sway-keybindings = {
    enable = mkEnableOption "Sway keybindings";

    brightnessStep = mkOption {
      type = types.str;
      default = "5";
      description = "Brightness change step percentage";
    };

    volumeStep = mkOption {
      type = types.str;
      default = "5";
      description = "Volume change step (numeric value without %)";
    };

    volumeLimit = mkOption {
      type = types.str;
      default = "100";
      description = "Maximum volume percentage (numeric value without %)";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.sway.config.keybindings =
      let
        mod = "Mod4";
      in
      {
        # Basic bindings
        "${mod}+Return" = "exec ghostty";
        "${mod}+Shift+Return" = "exec brave --enable-features=UseOzonePlatform --ozone-platform=wayland";
        "${mod}+Shift+n" = "exec nautilus";
        "${mod}+Shift+q" = "kill";
        "${mod}+Space" = "exec rofi -terminal 'ghostty' -show combi -combi-modes drun#run -modes combi";
        "${mod}+Shift+v" =
          "exec mpv --really-quiet --speed=0.5 --vo=wlshm --stop-screensaver --fullscreen --no-audio --shuffle --loop-playlist=inf $HOME/Videos/MovingWallpaper/";

        # 1Password quick access
        "${mod}+q" = "exec 1password --quick-access";

        # Lock screen
        "${mod}+Escape" =
          "exec swaylock --clock --indicator --screenshots --effect-scale 0.4 --effect-vignette 0.2:0.5 --effect-blur 4x2 --datestr '%a %e.%m.%Y' --timestr '%k:%M' -f";

        # Focus toggle between tiled and floating
        "${mod}+Tab" = "focus mode_toggle";

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

        # Resize mode
        "${mod}+r" = "mode resize";

        # Passthrough mode (toggle with Mod+Shift+Escape)
        "${mod}+Shift+Escape" = "mode passthrough";

        # Brightness controls
        "XF86MonBrightnessDown" =
          "exec '${pkgs.brightnessctl}/bin/brightnessctl -q set ${cfg.brightnessStep}%- && ${brightnessNotification}'";
        "XF86MonBrightnessUp" =
          "exec '${pkgs.brightnessctl}/bin/brightnessctl -q set +${cfg.brightnessStep}% && ${brightnessNotification}'";

        # Media controls (allow when locked)
        "--locked XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "--locked XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";
        "XF86AudioForward" = "exec ${pkgs.playerctl}/bin/playerctl position +10";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl pause";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
        "XF86AudioRewind" = "exec ${pkgs.playerctl}/bin/playerctl position -10";

        # Screenshot controls - save to XDG_SCREENSHOTS_DIR and copy to clipboard
        # For laptop keyboard with Print key
        "Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot savecopy active";
        "Shift+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot savecopy area";
        # For external keyboard without Print key
        "${mod}+p" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot savecopy active";
        "${mod}+Shift+p" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot savecopy area";

        # Volume controls (allow when locked)
        "--locked XF86AudioRaiseVolume" =
          "exec ${volumeHelper} --limit '${cfg.volumeLimit}' --increase '${cfg.volumeStep}'";
        "--locked XF86AudioLowerVolume" =
          "exec ${volumeHelper} --limit '${cfg.volumeLimit}' --decrease '${cfg.volumeStep}'";
        "--locked XF86AudioMute" = "exec ${volumeHelper} --toggle-mute";
        "--locked XF86AudioMicMute" = "exec ${volumeHelper} --toggle-mic-mute";
      };

    # Modes
    wayland.windowManager.sway.config.modes = {
      resize = {
        "h" = "resize shrink width 40px";
        "j" = "resize grow height 40px";
        "k" = "resize shrink height 40px";
        "l" = "resize grow width 40px";
        "Return" = "mode default";
        "Escape" = "mode default";
      };

      # Passthrough mode - passes all keys to focused application
      passthrough = {
        "Mod4+Shift+Escape" = "mode default";
      };
    };
  };
}
