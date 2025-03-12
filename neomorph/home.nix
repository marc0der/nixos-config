{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "marco";
  home.homeDirectory = "/home/marco";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    bibata-cursors
    dunst
    foot

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
      name = "Materia-light";
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
    # qt config
    ".config/qt5ct/qt5ct.conf".source = qt/qt5ct.conf;
    ".config/qt6ct/qt6ct.conf".source = qt/qt6ct.conf;

    # dunst
    ".config/dunst/dunstrc".source = dunst/dunstrc;

    # waybar
    ".config/waybar/config.jsonc".source = waybar/config.jsonc;
    ".config/waybar/style.css".source = waybar/style.css;

    # kanshi
    ".config/systemd/user/kanshi.service".source = systemd/kanshi.service;

    # slack
    ".local/share/applications/slack.desktop".source = desktop/slack.desktop;
  };

  home.sessionVariables = {
    GTK_THEME = "Materia-light";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
  };
}
