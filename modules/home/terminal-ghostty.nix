# Ghostty Terminal Module
#
# Unconditionally configures the Ghostty terminal emulator for the user:
# JetBrains Mono NL Light at 11pt, 95% background opacity, pywal-themed via
# ~/.cache/wal/colors-ghostty, zsh integration, and shift+Enter inserting a
# literal newline. Has no options; imported by every host from
# `commonHomeModules` in `flake.nix`.
#
# Options:
#   (none)
#
# Example usage:
#   imports = [ ./modules/home/terminal-ghostty.nix ];

{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
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
