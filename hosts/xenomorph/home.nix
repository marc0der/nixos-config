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

    # hyprland packages
    hyprland
    hyprpaper
    hypridle
    hyprlock
    hyprpolkitagent
    hyprshot
    swaynotificationcenter
    gnome-keyring
    polkit_gnome
  ];

  # GTK theme configuration
  gtk-theme.variant = "dark";

  # XDG portal configuration
  xdg-portal-hyprland.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/terminal" = [ "ghostty.desktop" ];
    };
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

  # Enable services to start with graphical session under UWSM
  services = {
    gnome-keyring = {
      enable = true;
      components = [ "secrets" ];
    };
    network-manager-applet.enable = true;
    hypridle.enable = true;
    hyprpaper.enable = true;
  };

}
