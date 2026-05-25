{ lib, ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    # Defaults via mkDefault so hosts can override any setting in their home.nix
    settings = lib.mkDefault {
      font-family = "JetBrains Mono NL Light";
      font-size = 11;
      background-opacity = 0.95;
      cursor-style = "block";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor";
      theme = "/home/marco/.cache/wal/colors-ghostty";
      gtk-titlebar = false;
      keybind = "shift+enter=text:\\n";
    };
  };
}
