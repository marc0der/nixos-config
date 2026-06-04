# Hyprland Keybindings Module
#
# All Hyprland keybindings: launchers, window management, focus/move, workspace
# switching, screenshot, audio/brightness, mouse binds, and the resize submap.
# Mirrors `modules/home/sway-keybindings.nix` for the Hyprland compositor.
#
# Options:
#   hyprland-keybindings.enable - Enable Hyprland keybindings (default: false)
#
# Example usage:
#   hyprland-keybindings.enable = true;

{
  config,
  lib,
  ...
}:

with lib;

{
  options.hyprland-keybindings = {
    enable = mkEnableOption "Hyprland keybindings";
  };

  config = mkIf config.hyprland-keybindings.enable {
    wayland.windowManager.hyprland.settings = {
      # Program definitions used by keybindings
      "$terminal" = "ghostty";
      "$fileManager" = "nautilus";
      "$menu" = "rofi -show drun";
      "$browser" = "brave --enable-features=UseOzonePlatform --ozone-platform=wayland";
      "$passmanager" = "1password --quick-access";

      # Main modifier key
      "$mainMod" = "SUPER";

      # Keybindings
      bind = [
        # Application launchers
        "$mainMod, RETURN, exec, $terminal"
        "$mainMod SHIFT, RETURN, exec, $browser"
        "$mainMod SHIFT, N, exec, $fileManager"
        "$mainMod, SPACE, exec, $menu"
        "$mainMod, Q, exec, $passmanager"

        # Window management
        "$mainMod SHIFT, Q, killactive"
        "$mainMod SHIFT, E, exec, wlogout"
        "$mainMod SHIFT, F, togglefloating"
        "$mainMod, P, pseudo"
        "$mainMod, T, layoutmsg, togglesplit"
        "$mainMod, F, fullscreen"
        "$mainMod, ESCAPE, exec, hyprlock"

        # Screenshots
        "$mainMod, Print, exec, hyprshot -m window -o ~/Pictures/Screenshots/ -f screenshot_win_$(date +'%Y-%m-%d_%H-%M-%S').png"
        "$mainMod SHIFT, Print, exec, hyprshot -m region -o ~/Pictures/Screenshots/ -f screenshot_region_$(date +'%Y-%m-%d_%H-%M-%S').png"
        "$mainMod CTRL, Print, exec, hyprshot -m region --clipboard-only"

        # Focus movement
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        # Workspace switching
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod CTRL, h, workspace, e-1"
        "$mainMod CTRL, l, workspace, e+1"

        # Move window on workspace
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, j, movewindow, d"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, l, movewindow, r"

        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Mouse workspace switching
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Resize submap
        "$mainMod, R, submap, resize"
      ];

      # Repeatable binds
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      # Locked binds (work even when locked)
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Mouse binds
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };

    # Resize submap (concatenated after hyprland-config's pywal extraConfig)
    wayland.windowManager.hyprland.extraConfig = mkAfter ''
      # Resize submap bindings
      submap = resize
      binde = , l, resizeactive, 10 0
      binde = , h, resizeactive, -10 0
      binde = , k, resizeactive, 0 -10
      binde = , j, resizeactive, 0 10
      bind = , escape, submap, reset
      submap = reset
    '';
  };
}
