# Work Profile
#
# This profile module provides work-related desktop entries for
# communication and collaboration tools like Slack and Google Meet.
#
# Options:
#   profiles.work.enable - Enable work-related desktop entries
#
# Example usage:
#   profiles.work.enable = true;

{
  config,
  lib,
  ...
}:

let
  cfg = config.profiles.work;
in
{
  options.profiles.work = {
    enable = lib.mkEnableOption "work profile";
  };

  config = lib.mkIf cfg.enable {
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

      microsoftTeams = {
        name = "Microsoft Teams";
        comment = "Microsoft Teams Collaboration";
        genericName = "Microsoft Teams in Brave";
        exec = ''brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Default --app="https://teams.microsoft.com/v2/"'';
        icon = "teams";
        type = "Application";
        startupNotify = true;
        categories = [
          "GNOME"
          "GTK"
          "Network"
          "InstantMessaging"
          "VideoConference"
        ];
      };
    };
  };
}
