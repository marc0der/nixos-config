{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    dunst
    foot
    obs-studio
    sway
    sway-contrib.grimshot
    swaylock-effects
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];

  gtk = {
    theme = {
      name = "Materia-Light";
      package = pkgs.materia-theme;
    };

    iconTheme = {
      name = "Papirus-Light";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.file = {
  };

  home.sessionVariables = {
    GTK_THEME = "Materia-Light";
    XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/json" = [ "gedit.desktop" ];
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
      "application/xml" = [ "gedit.desktop" ];
      "application/zip" = [ "org.gnome.FileRoller.desktop" ];
      "image/gif" = [ "org.gnome.eog.desktop" ];
      "image/jpeg" = [ "org.gnome.eog.desktop" ];
      "image/png" = [ "org.gnome.eog.desktop" ];
      "image/svg+xml" = [ "org.gnome.eog.desktop" ];
      "text/html" = [ "brave-browser.desktop" ];
      "text/markdown" = [ "gedit.desktop" ];
      "text/plain" = [ "gedit.desktop" ];
      "video/mp4" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "x-scheme-handler/about" = [ "brave-browser.desktop" ];
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "x-scheme-handler/terminal" = [ "foot.desktop" ];
      "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    config.common.default = "*";
  };

  xdg.desktopEntries = {
    slackDefra = {
      name = "Slack (DEFRA)";
      comment = "DEFRA Slack";
      genericName = "DEFRA Slack in Brave";
      exec = "brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Defra --app=\"https://app.slack.com/client/T73HZJ85R/C09C11N6DGA\"";
      icon = "slack";
      type = "Application";
      startupNotify = true;
      categories = [
        "GNOME"
        "GTK"
        "Network"
        "InstantMessaging"
      ];
      mimeType = [ "x-scheme-handler/slack" ];
    };

    slackEqualExperts = {
      name = "Slack (Equal Experts)";
      comment = "EE Slack";
      genericName = "EE Slack in Brave";
      exec = "brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Default --app=\"https://app.slack.com/client/T02QA1EAG\"";
      icon = "slack";
      type = "Application";
      startupNotify = true;
      categories = [
        "GNOME"
        "GTK"
        "Network"
        "InstantMessaging"
      ];
      mimeType = [ "x-scheme-handler/slack" ];
    };
  };

  systemd.user.services.xdg-desktop-portal-wlr = {
    Unit = {
      Description = "xdg-desktop-portal-wlr";
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
