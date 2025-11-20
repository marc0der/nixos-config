{
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    ansible
    ardour
    discord
    doctl
    ffmpeg
    musescore
    transcribe
    yt-dlp
  ];

  # Hyprland desktop environment
  hyprland-desktop.enable = true;

  # Hyprland window manager configuration
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor configuration
      monitor = [
        "desc:Dell Inc. DELL U3219Q 38RYXV2,preferred,0x0,1"
        "desc:Samsung Display Corp. 0x419F,preferred,970x2160,1.5"
        ",preferred,auto,1"
      ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # Program definitions
      "$terminal" = "ghostty";
      "$fileManager" = "nautilus";
      "$menu" = "rofi -show drun";
      "$browser" = "brave --enable-features=UseOzonePlatform --ozone-platform=wayland";
      "$passmanager" = "1password --quick-access";

      # Autostart applications
      exec-once = [
        "1password --silent"
        "flatpak run com.borgbase.Vorta --daemonize"
        "wal -i $(hyprctl hyprpaper listactive | cut -d '=' -f 2 | xargs)"
      ];

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        resize_on_border = false;
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
        pseudotile = true;
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
        kb_layout = "gb";
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

      # Gestures
      gestures = {
        workspace_swipe = false;
      };

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
        "$mainMod, V, togglefloating"
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

      # Window rules
      windowrulev2 = [
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

      # Resize submap
      submap = [ "resize" ];
    };

    # Extra config for pywal colors and resize submap
    extraConfig = ''
      # Source pywal colors FIRST
      source = ~/.cache/wal/colors-hyprland.conf

      # Apply pywal colors to borders (must be after source)
      general {
        col.active_border = $color6 $color4 45deg
        col.inactive_border = $color3
      }

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

  # GTK theme configuration
  gtk-theme.variant = "dark";

  # XDG portal configuration
  xdg-portal-hyprland.enable = true;

  # XDG MIME types configuration
  xdg-mimetypes = {
    enable = true;
    terminal = "ghostty.desktop";
  };

  xdg.desktopEntries = {
    moises = {
      name = "Moises";
      comment = "Music Studio";
      exec = "brave --enable-features=UseOzonePlatform --ozone-platform=wayland --app=\"https://studio.moises.ai/library\"";
      icon = "Moises";
      terminal = false;
      type = "Application";
      categories = [
        "AudioVideo"
        "Music"
      ];
    };
  };

}
