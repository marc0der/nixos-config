# XDG MIME Types Configuration
#
# This module configures default applications for common file types.
# It provides options to override specific handlers like terminal and text editor.
#
# Options:
#   xdg-mimetypes.enable - Enable XDG MIME type configuration
#   xdg-mimetypes.terminal - Terminal emulator to use (default: "alacritty.desktop")
#   xdg-mimetypes.textEditor - Text editor to use (default: "nvim.desktop")
#
# Example usage:
#   xdg-mimetypes.enable = true;
#   xdg-mimetypes.terminal = "ghostty.desktop";

{
  config,
  lib,
  ...
}:

let
  cfg = config.xdg-mimetypes;
in
{
  options.xdg-mimetypes = {
    enable = lib.mkEnableOption "XDG MIME type configuration";

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "alacritty.desktop";
      description = "Default terminal emulator";
    };

    textEditor = lib.mkOption {
      type = lib.types.str;
      default = "nvim.desktop";
      description = "Default text editor";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        # Web browser
        "text/html" = [ "brave-browser.desktop" ];
        "x-scheme-handler/http" = [ "brave-browser.desktop" ];
        "x-scheme-handler/https" = [ "brave-browser.desktop" ];
        "x-scheme-handler/about" = [ "brave-browser.desktop" ];
        "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];

        # PDF viewer
        "application/pdf" = [ "org.gnome.Evince.desktop" ];

        # Image viewer
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "image/png" = [ "org.gnome.eog.desktop" ];
        "image/gif" = [ "org.gnome.eog.desktop" ];
        "image/svg+xml" = [ "org.gnome.eog.desktop" ];

        # Text editor
        "text/plain" = [ cfg.textEditor ];
        "text/markdown" = [ cfg.textEditor ];
        "application/json" = [ cfg.textEditor ];
        "application/xml" = [ cfg.textEditor ];

        # Video player
        "video/mp4" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
        "video/quicktime" = [ "mpv.desktop" ];

        # Archive files
        "application/zip" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];

        # Terminal
        "x-scheme-handler/terminal" = [ cfg.terminal ];
      };
    };
  };
}
