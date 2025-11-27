{
  pkgs,
  lib,
  ...
}:

{
  # Xenomorph-specific packages
  home.packages = with pkgs; [
    ansible
    discord
    doctl
  ];

  # Profile modules
  profiles.music-production.enable = true;

  # Desktop environment modules
  hyprland-desktop.enable = true;
  hyprland-config.enable = true;
  hyprland-rules.enable = true;
  hyprland-extras.enable = true;

  # GTK theme
  gtk-theme.variant = "dark";

  # XDG configuration
  xdg-portal-hyprland.enable = true;
  xdg-mimetypes = {
    enable = true;
    terminal = "ghostty.desktop";
  };
}
