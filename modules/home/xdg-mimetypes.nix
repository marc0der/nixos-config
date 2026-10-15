# XDG MIME Types Configuration
#
# This module configures default applications for common file types.
# It provides options to override specific handlers like terminal and text editor.
#
# Options:
#   local.xdg-mimetypes.enable - Enable XDG MIME type configuration
#   local.xdg-mimetypes.terminal - Terminal emulator to use (default: "ghostty.desktop")
#   local.xdg-mimetypes.textEditor - Text editor to use (default: "nvim.desktop")
#   local.xdg-mimetypes.pdfViewer - PDF viewer (default: "org.gnome.Evince.desktop")
#   local.xdg-mimetypes.imageViewer - Image viewer (default: "org.gnome.eog.desktop")
#   local.xdg-mimetypes.archiveManager - Archive manager (default: "org.gnome.FileRoller.desktop")
#
# Example usage:
#   local.xdg-mimetypes.enable = true;
#   local.xdg-mimetypes.terminal = "ghostty.desktop";

{
  config,
  lib,
  ...
}:

let
  cfg = config.local.xdg-mimetypes;
in
{
  options.local.xdg-mimetypes = {
    enable = lib.mkEnableOption "XDG MIME type configuration";

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "ghostty.desktop";
      description = "Default terminal emulator";
    };

    textEditor = lib.mkOption {
      type = lib.types.str;
      default = "nvim.desktop";
      description = "Default text editor";
    };

    pdfViewer = lib.mkOption {
      type = lib.types.str;
      default = "org.gnome.Evince.desktop";
      description = "Default PDF viewer";
    };

    imageViewer = lib.mkOption {
      type = lib.types.str;
      default = "org.gnome.eog.desktop";
      description = "Default image viewer";
    };

    archiveManager = lib.mkOption {
      type = lib.types.str;
      default = "org.gnome.FileRoller.desktop";
      description = "Default archive manager";
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
        "application/pdf" = [ cfg.pdfViewer ];

        # Image viewer
        "image/jpeg" = [ cfg.imageViewer ];
        "image/png" = [ cfg.imageViewer ];
        "image/gif" = [ cfg.imageViewer ];
        "image/svg+xml" = [ cfg.imageViewer ];

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
        "application/zip" = [ cfg.archiveManager ];
        "application/x-compressed-tar" = [ cfg.archiveManager ];
        "application/x-tar" = [ cfg.archiveManager ];
        "application/x-7z-compressed" = [ cfg.archiveManager ];

        # Terminal
        "x-scheme-handler/terminal" = [ cfg.terminal ];

        # Claude Code deep links
        "x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];

        # JetBrains Toolbox deep links
        "x-scheme-handler/jetbrains" = [ "jetbrainsd.desktop" ];
      };
    };

    # Reclaim mimeapps.list when apps overwrite it
    xdg.configFile."mimeapps.list".force = true;
  };
}
