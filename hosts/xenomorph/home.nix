{
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    ansible
    ardour
    discord
    doctl
    ffmpeg
    musescore
    transcribe
    yt-dlp
  ];

  # Hyprland desktop environment
  hyprland-desktop.enable = true;

  # GTK theme configuration
  gtk-theme.variant = "dark";

  # XDG portal configuration
  xdg-portal-hyprland.enable = true;

  # XDG MIME types configuration
  xdg-mimetypes = {
    enable = true;
    terminal = "ghostty.desktop";
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
        "AudioVideo"
        "Music"
      ];
    };
  };

}
