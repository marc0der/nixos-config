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
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];

  gtk = {
    theme = {
      name = "Materia-Dark";
      package = pkgs.materia-theme;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.sessionVariables = {
    GTK_THEME = "Materia-Dark";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/terminal" = [ "ghostty.desktop" ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config = {
      common = {
        default = "gtk";
      };
      hyprland = {
        default = [
          "gtk"
          "hyprland"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
        "org.freedesktop.impl.portal.Screenshot" = "hyprland";
      };
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
    gpg-agent = {
      sshKeys = [ "A18D2A102BDBA1DEED0F4BCE79834B4865124319" ];
    };
  };

}
