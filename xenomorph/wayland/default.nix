# This file contains the hyprland configuration for xenomorph
# Currently using the "raw files" approach before converting to pure Nix

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Install required packages for hyprland setup
  home.packages = with pkgs; [
    hyprland
    hyprpaper
    hypridle
    hyprlock
    hyprshot
    waybar
    wlogout
    swaynotificationcenter
    pywal
    playerctl
    brightnessctl
    rofi
    (writeShellScriptBin "hypridle-control" (builtins.readFile ./scripts/hypridle.sh))
    (writeShellScriptBin "apply-pywal-theme" (builtins.readFile ./scripts/apply-pywal-theme.sh))
  ];

  # Create symlinks to the configuration files
  home.file = {
    # Hyprland and related configs
    ".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
    ".config/hypr/hypridle.conf".source = ./hypr/hypridle.conf;
    ".config/hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;
    ".config/hypr/hyprpaper.conf".source = ./hypr/hyprpaper.conf;
    ".config/hypr/scripts/hypridle.sh" = {
      source = ./scripts/hypridle.sh;
      executable = true;
    };

    # Waybar
    ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
    ".config/waybar/modules.json".source = ./waybar/modules.json;
    ".config/waybar/style.css".source = ./waybar/style.css;

    # SwayNC
    ".config/swaync/config.json".source = ./swaync/config.json;
    ".config/swaync/style.css".source = ./swaync/style.css;

    # Wlogout
    ".config/wlogout/layout".source = ./wlogout/layout;
    ".config/wlogout/style.css".source = ./wlogout/style.css;
    ".config/wlogout/noise.png".source = ./wlogout/noise.png;
    ".config/wlogout/icons/hibernate.png".source = ./wlogout/icons/hibernate.png;
    ".config/wlogout/icons/lock.png".source = ./wlogout/icons/lock.png;
    ".config/wlogout/icons/logout.png".source = ./wlogout/icons/logout.png;
    ".config/wlogout/icons/reboot.png".source = ./wlogout/icons/reboot.png;
    ".config/wlogout/icons/shutdown.png".source = ./wlogout/icons/shutdown.png;
    ".config/wlogout/icons/suspend.png".source = ./wlogout/icons/suspend.png;

    # We don't manage the wallpaper through Nix to allow for easy updates
  };

  # Enable hypridle service
  systemd.user.services.hypridle = {
    Unit = {
      Description = "Hypridle service";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hypridle}/bin/hypridle";
      Restart = "always";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Enable swaync service
  systemd.user.services.swaync = {
    Unit = {
      Description = "Swaync notification daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
      Restart = "always";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
