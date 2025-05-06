{ ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        pad = "15x15";
        shell = "zsh";
      };

      cursor = {
        style = "block";
        blink = "no";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
