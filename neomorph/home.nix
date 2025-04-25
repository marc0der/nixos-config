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
    steam-run
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
    ".local/share/applications/slack.desktop".source = desktop/slack.desktop;
  };

  home.sessionVariables = {
    GTK_THEME = "Materia-Light";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/zoommtg" = [ "zoom.desktop" ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    config.common.default = "*";
  };

  xdg.desktopEntries.zoom = {
    name = "Zoom (FHS)";
    exec = "${pkgs.writeShellScriptBin "zoom-wrapper" ''
      exec ${pkgs.steam-run}/bin/steam-run ${pkgs.zoom-us}/bin/zoom %U
    ''}";
    mimeType = [ "x-scheme-handler/zoommtg" ];
    noDisplay = false;
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
