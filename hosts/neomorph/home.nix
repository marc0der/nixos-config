{
  config,
  pkgs,
  backlogMd,
  ...
}:

let
  # Backlog.md zsh completion (lands on $fpath via profile site-functions)
  backlogZshCompletion = pkgs.runCommand "backlog-zsh-completion" { } ''
    mkdir -p "$out/share/zsh/site-functions" home
    HOME="$PWD/home" ${backlogMd}/bin/backlog completion install --shell zsh
    install -Dm644 "$PWD/home/.zsh/completions/_backlog" \
      "$out/share/zsh/site-functions/_backlog"
  '';
in
{
  # Host-specific packages
  home.packages = with pkgs; [
    backlogMd
    backlogZshCompletion
    google-chrome
    kdePackages.kcalc
    pnpm
  ];

  # Ghostty: larger font on this host
  programs.ghostty.settings.font-size = 13;

  # SSH configuration
  local.ssh-config.enable = true;

  # Brave: personal profile lives in its own directory on this host
  local.web-app-launchers.personalProfile = "Marco";

  # Keyring services: KWallet and Plasma's PolKit agent take over
  local.keyring-services = {
    gnomeKeyring = false;
    pinentry = pkgs.pinentry-qt;
    polkitAgent = false;
  };

  # Profiles
  local.profiles.music-production.enable = true;
  local.profiles.work.enable = true;

  # Zoom: native client with KIO URL wrapper
  local.zoom.enable = true;

  # GTK theme: off, Plasma manages GTK settings
  local.gtk-theme.enable = false;

  # XDG portal configuration
  local.xdg-portal-plasma.enable = true;

  # XDG MIME types configuration
  local.xdg-mimetypes = {
    enable = true;
    terminal = "com.mitchellh.ghostty.desktop";
    textEditor = "org.kde.kate.desktop";
    pdfViewer = "org.kde.okular.desktop";
    imageViewer = "org.kde.gwenview.desktop";
    archiveManager = "org.kde.ark.desktop";
  };

  # Shared scripts
  local.home-scripts.enable = true;

  # AppImage launchers: binaries live in ~/Applications
  xdg.desktopEntries.device-check = {
    name = "Device Check";
    exec = "${config.home.homeDirectory}/Applications/device-check.AppImage";
    icon = "${../../icons/device-check.png}";
    type = "Application";
    settings.StartupWMClass = "device-check";
  };
}
