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
    ".local/share/applications/zoom.desktop".source = desktop/zoom.desktop;
  };

  home.sessionVariables = {
    GTK_THEME = "Materia-Light";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
  };

}
