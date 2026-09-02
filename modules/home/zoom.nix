# Zoom Module
#
# Installs the native Zoom client together with a URL wrapper that repairs
# meeting and sign-in links mangled by KDE's KIO before handing them to Zoom.
# Registers the wrapper as the default handler for every Zoom URL scheme so
# browser links reach the running client intact.
#
# Options:
#   local.zoom.enable - Enable Zoom and its URL wrapper (default: false)
#
# Example usage:
#   local.zoom.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.zoom;

  schemes = [
    "zoommtg"
    "zoomus"
    "zoomphonecall"
    "zoomphonesms"
    "zoomcontactcentercall"
  ];

  handler = [ "Zoom.desktop" ];
in
{
  options.local.zoom = {
    enable = lib.mkEnableOption "Zoom client with KIO URL wrapper";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.zoom-us ];

    home.file."bin/zoom-url" = {
      source = ./scripts/zoom-url.sh;
      executable = true;
    };

    # Shadows the zoom-us package's Zoom.desktop from XDG_DATA_HOME, so exactly
    # one handler claims the Zoom schemes and no app chooser appears.
    home.file.".local/share/applications/Zoom.desktop".text = ''
      [Desktop Entry]
      Name=Zoom Workplace
      Comment=Zoom Video Conference
      Exec=${config.home.homeDirectory}/bin/zoom-url %U
      Icon=Zoom
      Terminal=false
      Type=Application
      Encoding=UTF-8
      Categories=Network;Application;
      StartupWMClass=zoom
      StartupNotify=true
      MimeType=${lib.concatMapStrings (s: "x-scheme-handler/${s};") schemes}application/x-zoom
      X-KDE-Protocols=${lib.concatStringsSep ";" schemes}
    '';

    xdg.mimeApps.defaultApplications = lib.genAttrs (map (s: "x-scheme-handler/${s}") schemes) (
      _: handler
    );

    # Refresh the mimeinfo cache for the shadowing entry above
    home.activation.zoomDesktopDatabase = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run ${pkgs.desktop-file-utils}/bin/update-desktop-database -q \
        "$HOME/.local/share/applications" || true
    '';
  };
}
