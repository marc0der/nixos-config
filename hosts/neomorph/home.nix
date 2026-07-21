{ pkgs, backlogMd, ... }:

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
    pnpm
  ];

  # Ghostty: larger font on this host
  programs.ghostty.settings.font-size = 13;

  # SSH configuration
  local.ssh-config.enable = true;

  # Desktop environment
  local.sway-desktop.enable = true;
  local.sway-config.enable = true;
  local.sway-rules.enable = true;
  local.sway-keybindings.enable = true;
  local.sway-startup.enable = true;
  local.kanshi.enable = true;

  # Workspace 1 default layout: Slack left, Brave right
  wayland.windowManager.sway.config.startup = [
    { command = "/home/marco/bin/arrange-workspace1"; }
  ];

  # Profiles
  local.profiles.music-production.enable = true;
  local.profiles.work.enable = true;

  # SiriusXM VPN shell proxy (opt-in via `sxm-proxy on`)
  local.sxm-proxy.enable = true;

  # SiriusXM team drive mounted at ~/SharedDrives/Workspace
  local.google-drive-mount.enable = true;

  # GTK theme configuration
  local.gtk-theme.variant = "dark";

  # XDG portal configuration
  local.xdg-portal-sway.enable = true;

  # XDG MIME types configuration
  local.xdg-mimetypes = {
    enable = true;
    terminal = "ghostty.desktop";
    textEditor = "gedit.desktop";
  };

  # Shared scripts
  local.home-scripts.enable = true;
}
