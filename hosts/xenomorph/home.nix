{ pkgs, ... }:

{
  # Host-specific packages
  home.packages = with pkgs; [
    ansible
    discord
    doctl
    ffmpeg
    libplacebo
    mkvtoolnix
    tesseract
    video2x
    vobsub2srt

    # GNOME apps
    eog
    evince
    file-roller
    font-manager
    gedit
    gnome-calculator
    nautilus
    pinentry-gnome3
    polkit_gnome

    # Hyprland session tools
    cliphist
    wl-mirror
    wlogout

    # GTK and Qt theming tools
    materia-theme
    papirus-icon-theme
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qt6ct
  ];

  # Common desktop packages
  local.desktop-common.enable = true;

  # SSH configuration
  local.ssh-config.enable = true;

  # Desktop environment
  local.hyprland-desktop.enable = true;
  local.hyprland-config.enable = true;
  local.hyprland-rules.enable = true;
  local.hyprland-keybindings.enable = true;
  local.hyprland-startup.enable = true;
  local.hyprland-extras.enable = true;

  # Profiles
  local.profiles.music-production.enable = true;

  # GTK theme configuration
  local.gtk-theme.variant = "dark";

  # XDG portal configuration
  local.xdg-portal-hyprland.enable = true;

  # XDG MIME types configuration
  local.xdg-mimetypes = {
    enable = true;
    terminal = "com.mitchellh.ghostty.desktop";
  };
}
