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
    playerctl
    brightnessctl
    rofi
    gnome.gnome-keyring
    polkit_gnome
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

    # Pywal templates - only the ones not conflicting with the Hyprland setup
    ".config/wal/templates/colors-dunst".source = ./templates/colors-dunst;
    ".config/wal/templates/colors-swaylock.conf".source = ./templates/colors-swaylock.conf;

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
  
  # Add an activation script to run pywal when home-manager is activated
  home.activation.applyPywalTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Applying pywal theme to current wallpaper..."
    # Make sure PATH includes the profile bin directory
    export PATH=$PATH:$HOME/.nix-profile/bin:/run/current-system/sw/bin
    apply-pywal-theme
  '';
}
