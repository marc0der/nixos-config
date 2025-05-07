{
  config,
  pkgs,
  unstable,
  ...
}:

{
  home.packages = with pkgs; [
    brave
    dunst
    foot
    kanshi
    playerctl
    rofi
    sway-contrib.grimshot
    swaylock-effects
    waybar
    wl-clipboard
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    zoom-us

    # themes
    materia-theme
    papirus-icon-theme
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    qt6ct
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Materia-Light";
      package = pkgs.materia-theme;
    };

    iconTheme = {
      name = "Papirus-Light";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };
  };

  home.file = {
  };

  home.sessionVariables = {
    GTK_THEME = "Materia-Light";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/terminal" = [ "foot.desktop" ];
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
    slack = {
      name = "Slack Equal Experts";
      comment = "EE Slack";
      genericName = "EE Slack in Brave";
      exec = "brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --app=\"https://app.slack.com/client/T02QA1EAG\"";
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

    braveDefault = {
      name = "Browser (Equal Experts)";
      genericName = "Web Browser";
      comment = "Equal Experts Browser Profile";
      exec = "brave --profile-directory=Default --enable-features=UseOzonePlatform --ozone-platform=wayland";
      icon = "brave";
      terminal = false;
      type = "Application";
      categories = [
        "Network"
        "WebBrowser"
        "GTK"
      ];
      startupNotify = false;
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/xml"
        "application/rss+xml"
        "application/rdf+xml"
        "image/gif"
        "image/jpeg"
        "image/png"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/ftp"
        "x-scheme-handler/chrome"
      ];
    };

    bravePersonal = {
      name = "Browser (Personal)";
      genericName = "Web Browser";
      comment = "Personal Browser Profile";
      exec = "brave --profile-directory=\"Profile 1\" --enable-features=UseOzonePlatform --ozone-platform=wayland";
      icon = "brave";
      terminal = false;
      type = "Application";
      categories = [
        "Network"
        "WebBrowser"
        "GTK"
      ];
      startupNotify = false;
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/xml"
        "application/rss+xml"
        "application/rdf+xml"
        "image/gif"
        "image/jpeg"
        "image/png"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/ftp"
        "x-scheme-handler/chrome"
      ];
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
