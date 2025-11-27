{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = "JetBrains Mono NL Light";
      font-size = 11;
      background-opacity = 0.8;
      cursor-style = "block";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor";
      theme = "/home/marco/.cache/wal/colors-ghostty";
      gtk-titlebar = false;
    };
  };
}
