{ pkgs, ... }:

{
  # Host-specific packages
  home.packages = with pkgs; [
    kotlin-lsp
    ansible
    jetbrains.idea
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
  ssh-config.enable = true;

  # Desktop environment
  hyprland-desktop.enable = true;
  hyprland-config.enable = true;
  hyprland-rules.enable = true;
  hyprland-extras.enable = true;

  # Profiles
  profiles.music-production.enable = true;

  # GTK theme configuration
  gtk-theme.variant = "dark";

  # XDG portal configuration
  xdg-portal-hyprland.enable = true;

  # XDG MIME types configuration
  xdg-mimetypes = {
    enable = true;
    terminal = "ghostty.desktop";
  };
}
