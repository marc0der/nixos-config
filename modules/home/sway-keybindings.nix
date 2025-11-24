# Sway Additional Keybindings Module
#
# Contains keybindings for brightness, media control, screenshots, and volume.
# Migrated from ~/.config/sway/config.d/60-bindings-*.conf
#
# Options:
#   sway-keybindings.enable - Enable additional keybindings (default: false)
#   sway-keybindings.brightnessStep - Brightness change step percentage (default: "5")
#   sway-keybindings.volumeStep - Volume change step (default: "5%")
#   sway-keybindings.volumeLimit - Maximum volume percentage (default: "100%")
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
    enable = mkEnableOption "Additional Sway keybindings";

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
  };
}
