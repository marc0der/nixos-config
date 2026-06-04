{ pkgs, ... }:

{
  # Host-specific packages
  home.packages = with pkgs; [
    ansible
    discord
    doctl
    ffmpeg
    libplacebo
    makemkv
    mkvtoolnix
    tesseract
    video2x
    vobsub2srt
  ];

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
    terminal = "ghostty.desktop";
  };
}
