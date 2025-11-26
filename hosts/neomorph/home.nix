{ pkgs, ... }:

{
  home.packages = with pkgs; [
    obs-studio
  ];

  # Sway desktop environment
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

  home.file = {
    "bin/volume-helper" = {
      source = ../../modules/home/scripts/volume-helper.sh;
      executable = true;
    };
  };
}
