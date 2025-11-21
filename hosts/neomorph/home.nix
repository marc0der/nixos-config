{ pkgs, ... }:

{
  home.packages = with pkgs; [
    obs-studio
  ];

  # Sway desktop environment
  sway-desktop.enable = true;

  # Music production profile
  profiles.music-production.enable = true;

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

  home.file = { };

  home.sessionVariables = {
    XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  xdg.desktopEntries = {
    slackDefraDigitalTeam = {
      name = "Slack (DEFRA Digital Team)";
      comment = "DEFRA Digital Team Slack";
      genericName = "DEFRA Digital Team Slack in Brave";
      exec = ''brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Defra --app="https://app.slack.com/client/T73HZJ85R/C09C11N6DGA"'';
      icon = "slack";
      type = "Application";
      startupNotify = true;
      categories = [
        "GNOME"
        "GTK"
        "Network"
        "InstantMessaging"
      ];
      mimeType = [ "x-scheme-handler/slack" ];
    };

    slackDefraDigital = {
      name = "Slack (DEFRA Digital)";
      comment = "DEFRA Digital Slack";
      genericName = "DEFRA Digital Slack in Brave";
      exec = ''brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Defra --app="https://app.slack.com/client/T0ESW1J2D/C0ESX6V26"'';
      icon = "slack";
      type = "Application";
      startupNotify = true;
      categories = [
        "GNOME"
        "GTK"
        "Network"
        "InstantMessaging"
      ];
      mimeType = [ "x-scheme-handler/slack" ];
    };

    slackEqualExperts = {
      name = "Slack (Equal Experts)";
      comment = "EE Slack";
      genericName = "EE Slack in Brave";
      exec = ''brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Default --app="https://app.slack.com/client/T02QA1EAG"'';
      icon = "slack";
      type = "Application";
      startupNotify = true;
      categories = [
        "GNOME"
        "GTK"
        "Network"
        "InstantMessaging"
      ];
      mimeType = [ "x-scheme-handler/slack" ];
    };

    googleMeet = {
      name = "Google Meet";
      comment = "Google Meet Video Conferencing";
      genericName = "Google Meet in Brave";
      exec = ''brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Default --app="https://meet.google.com"'';
      icon = "google-meet";
      type = "Application";
      startupNotify = true;
      categories = [
        "GNOME"
        "GTK"
        "Network"
        "VideoConference"
      ];
    };
  };
}
