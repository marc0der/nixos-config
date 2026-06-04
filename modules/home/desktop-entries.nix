# Brave web-app .desktop entries
#
# Registers XDG desktop entries that launch specific web apps as standalone
# Brave windows (Ozone Wayland) with their own icons: Groove Trainer, Todoist,
# ChatGPT, Claude, Discord. Bundled here so adding/removing an entry is a
# one-place change and home.nix stays focused on top-level configuration.
#
# Options:
#   local.web-app-launchers.enable - Install the Brave web-app .desktop entries
#
# Example usage:
#   local.web-app-launchers.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.local.web-app-launchers;
in
{
  options.local.web-app-launchers = {
    enable = lib.mkEnableOption "Brave web-app .desktop entries";
  };

  config = lib.mkIf cfg.enable {
    xdg.desktopEntries = {
      groove-trainer = {
        name = "Groove Trainer";
        exec = ''brave --enable-features=UseOzonePlatform --ozone-platform=wayland --app="https://scottsbasslessons.com/groove-trainer" %U'';
        terminal = false;
        type = "Application";
        categories = [
          "Network"
          "WebBrowser"
          "Education"
        ];
        comment = "Groove Trainer";
      };

      todoist = {
        name = "Todoist";
        exec = ''brave --enable-features=UseOzonePlatform --ozone-platform=wayland --app="https://app.todoist.com/app/filter/focus-2348004222" %U'';
        terminal = false;
        type = "Application";
        categories = [
          "Network"
          "Application"
        ];
        comment = "Todoist";
        icon = "Todoist";
      };

      chatgpt = {
        name = "ChatGPT";
        exec = ''brave --enable-features=UseOzonePlatform --ozone-platform=wayland --app="https://chatgpt.com/" %U'';
        terminal = false;
        type = "Application";
        categories = [
          "Network"
          "WebBrowser"
          "Utility"
        ];
        comment = "ChatGPT";
        icon = "chatgpt";
      };

      claude = {
        name = "Claude";
        exec = ''brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Default --app="https://claude.ai/" %U'';
        terminal = false;
        type = "Application";
        categories = [
          "Network"
          "WebBrowser"
          "Utility"
        ];
        comment = "Claude";
        icon = "claude-desktop";
      };

      discord = {
        name = "Discord";
        exec = ''brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Marco --app="https://discord.com/channels/@me/1474759623209783327" %U'';
        terminal = false;
        type = "Application";
        categories = [
          "Network"
          "InstantMessaging"
        ];
        comment = "Discord";
        icon = "discord";
      };
    };
  };
}
