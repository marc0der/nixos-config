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
  local.ssh-config.enable = true;

  # Desktop environment
  local.sway-desktop.enable = true;
  local.sway-config.enable = true;
  local.sway-rules.enable = true;
  local.sway-keybindings.enable = true;
  local.sway-startup.enable = true;

  # Workspace 1 default layout: Slack left, Brave right
  wayland.windowManager.sway.config.startup = [
    { command = "/home/marco/bin/arrange-workspace1"; }
  ];

  # Profiles
  local.profiles.music-production.enable = true;
  local.profiles.work.enable = true;

  # GTK theme configuration
  local.gtk-theme.variant = "dark";

  # XDG portal configuration
  local.xdg-portal-sway.enable = true;

  # XDG MIME types configuration
  local.xdg-mimetypes = {
    enable = true;
    terminal = "ghostty.desktop";
    textEditor = "gedit.desktop";
  };

  # Shared scripts
  local.home-scripts.enable = true;
}
