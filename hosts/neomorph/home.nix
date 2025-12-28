{ pkgs, ... }:

{
  # Host-specific packages
  home.packages = with pkgs; [
    obs-studio
  ];

  # SSH configuration
  ssh-config.enable = true;

  # Desktop environment
  sway-desktop.enable = true;
  sway-config.enable = true;
  sway-rules.enable = true;
  sway-keybindings.enable = true;

  # Profiles
  profiles.music-production.enable = true;
  profiles.work.enable = true;

  # GTK theme configuration
  gtk-theme.variant = "dark";

  # XDG portal configuration
  xdg-portal-sway.enable = true;

  # XDG MIME types configuration
  xdg-mimetypes = {
    enable = true;
    terminal = "ghostty.desktop";
    textEditor = "gedit.desktop";
  };

  # Shared scripts
  home-scripts.enable = true;
}
