{
  config,
  pkgs,
  unstable,
  ...
}:

{
  home.packages = with pkgs; [
    ansible
    ardour
    brave
    discord
    doctl
    ffmpeg
    hyprpolkitagent
    kanshi
    wl-clipboard

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
      name = "Materia-Dark";
      package = pkgs.materia-theme;
    };

    iconTheme = {
      name = "Papirus-Dark";
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
    GTK_THEME = "Materia-Dark";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
  };

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
        "Media"
        "Application"
      ];
    };
  };

}
