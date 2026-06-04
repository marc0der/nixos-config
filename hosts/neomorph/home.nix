{ pkgs, ... }:

{
  # Host-specific packages
  home.packages = with pkgs; [
    google-chrome
    pnpm
  ];

  # Ghostty: larger font on this host
  programs.ghostty.settings.font-size = 13;

  # SSH configuration
  ssh-config.enable = true;

  # Desktop environment
  sway-desktop.enable = true;
  sway-config.enable = true;
  sway-rules.enable = true;
  sway-keybindings.enable = true;
  sway-startup.enable = true;

  # Workspace 1 default layout: Slack left, Brave right
  wayland.windowManager.sway.config.startup = [
    { command = "/home/marco/bin/arrange-workspace1"; }
  ];

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
