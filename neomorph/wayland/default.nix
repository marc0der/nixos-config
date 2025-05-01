# This file contains the sway configuration for neomorph
# Currently using the "raw files" approach before converting to pure Nix

{ config, lib, pkgs, ... }:

{
  # Install required packages for sway setup
  # Note: many packages already included in home.nix files are not duplicated here
  home.packages = with pkgs; [ sway wl-clipboard ];

  # Create symlinks to the configuration files
  home.file = {
    # Sway config
    ".config/sway/config".source = ./sway/config;

    # Sway config.d directory
    ".config/sway/config.d/50-rules-blueman-manager.conf".source =
      ./sway/config.d/50-rules-blueman-manager.conf;
    ".config/sway/config.d/50-rules-browser.conf".source =
      ./sway/config.d/50-rules-browser.conf;
    ".config/sway/config.d/50-rules-network-manager.conf".source =
      ./sway/config.d/50-rules-network-manager.conf;
    ".config/sway/config.d/50-rules-pavucontrol.conf".source =
      ./sway/config.d/50-rules-pavucontrol.conf;
    ".config/sway/config.d/50-rules-policykit-agent.conf".source =
      ./sway/config.d/50-rules-policykit-agent.conf;
    ".config/sway/config.d/60-bindings-brightness.conf".source =
      ./sway/config.d/60-bindings-brightness.conf;
    ".config/sway/config.d/60-bindings-media.conf".source =
      ./sway/config.d/60-bindings-media.conf;
    ".config/sway/config.d/60-bindings-screenshot.conf".source =
      ./sway/config.d/60-bindings-screenshot.conf;
    ".config/sway/config.d/60-bindings-volume.conf".source =
      ./sway/config.d/60-bindings-volume.conf;
    ".config/sway/config.d/65-mode-passthrough.conf".source =
      ./sway/config.d/65-mode-passthrough.conf;
    ".config/sway/config.d/80-xdg-desktop-portal.conf".source =
      ./sway/config.d/80-xdg-desktop-portal.conf;
    ".config/sway/config.d/90-bar.conf".source = ./sway/config.d/90-bar.conf;
    ".config/sway/config.d/90-swayidle.conf".source =
      ./sway/config.d/90-swayidle.conf;
    ".config/sway/config.d/95-autostart-policykit-agent.conf".source =
      ./sway/config.d/95-autostart-policykit-agent.conf;
    ".config/sway/config.d/96-1password.conf".source =
      ./sway/config.d/96-1password.conf;

    # We don't manage the wallpaper through Nix to allow for easy updates
  };
}
