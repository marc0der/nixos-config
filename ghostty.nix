{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Font settings
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;

      # Appearance
      background-opacity = 0.8;

      # Cursor settings
      cursor-style = "block";
      cursor-style-blink = false;

      # Disable shell integration features that would override cursor
      shell-integration-features = "no-cursor";

      # Theme
      theme = "/home/marco/.cache/wal/colors-ghostty";
    };
  };
}
