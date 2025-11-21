# Music Production Profile
#
# This profile module provides music production and audio/video tools
# used for music creation, recording, editing, and transcription.
#
# Options:
#   profiles.music-production.enable - Enable music production packages and tools
#
# Example usage:
#   profiles.music-production.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.music-production;
in
{
  options.profiles.music-production = {
    enable = lib.mkEnableOption "music production profile";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ardour
      musescore
      transcribe
      ffmpeg
      yt-dlp
    ];

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
  };
}
