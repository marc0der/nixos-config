{
  config,
  pkgs,
  claudeDesktop,
  unstable,
  ...
}:

{

  home.username = "marco";
  home.homeDirectory = "/home/marco";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    autojump
    bat
    bibata-cursors
    blueman
    borgbackup
    brave
    brightnessctl
    chafa
    cliphist
    desktop-file-utils
    eog
    evince
    file-roller
    font-manager
    fzf
    gedit
    gh
    gnome-calculator
    htop
    httpie
    jetbrains.idea-ultimate
    jq
    kanshi
    lazygit
    meld
    mpv
    nautilus
    ncdu
    neofetch
    networkmanagerapplet
    nixfmt-rfc-style
    nodejs
    nodePackages.jsonlint
    obsidian
    pavucontrol
    pinentry-gnome3
    playerctl
    protonvpn-cli
    protonvpn-gui
    python3
    pywal
    ripgrep
    rofi
    speedtest-rs
    uv
    vscode
    waybar
    wl-clipboard
    wlogout
    yamllint
    zsh-powerlevel10k

    # Unstable packages
    unstable.code-cursor
    unstable.claude-code
    claudeDesktop.claude-desktop

    # Shared themes
    materia-theme
    papirus-icon-theme
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    qt6ct

    # fonts
    font-awesome
    noto-fonts
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    fira-sans
    jetbrains-mono
    (pkgs.nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "Noto"
      ];
    })
  ];

  home.file = {
    ".gnupg/gpg-agent.conf".source = gnupg/gpg-agent.conf;
    ".gnupg/gpg.conf".source = gnupg/gpg.conf;
    ".config/qt5ct/qt5ct.conf".source = qt/qt5ct.conf;
    ".config/qt6ct/qt6ct.conf".source = qt/qt6ct.conf;
    ".local/share/icons/chatgpt.png".source = icons/chatgpt.png;
    ".local/share/icons/claude-desktop.png".source = icons/claude-desktop.png;
    ".claude/agents/git-committer.md".source = claude/agents/git-committer.md;
  };

  fonts.fontconfig.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 11;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
  };

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/nixos/bin"
  ];

  home.changes-report.enable = true;

  programs.home-manager.enable = true;

  xdg = {
    enable = true;

    # Default applications
    mimeApps = {
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
        "text/plain" = [ "nvim.desktop" ];
        "text/markdown" = [ "nvim.desktop" ];
        "application/json" = [ "nvim.desktop" ];
        "application/xml" = [ "nvim.desktop" ];

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
      };
    };
  };

  services.gnome-keyring = {
    enable = true;
    components = [
      "pkcs11"
      "secrets"
      "ssh"
    ];
  };

  systemd.user.services.google-drive = {
    Unit = {
      Description = "Google Drive mount";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      Environment = [
        "RCLONE_CONFIG=%h/.config/rclone/rclone.conf"
        "PATH=/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:%h/.nix-profile/bin"
      ];
      KillMode = "none";
      RestartSec = 5;
      ExecStartPre = "/run/current-system/sw/bin/bash -c 'until /run/current-system/sw/bin/ping -c1 8.8.8.8; do sleep 1; done'";
      ExecStart = toString [
        "/run/current-system/sw/bin/rclone"
        "mount"
        "drive:Share"
        "%h/Share"
        "--dir-cache-time"
        "8760h"
        "--poll-interval"
        "30s"
        "--log-file"
        "/tmp/rclone-gdrive.log"
        "--log-level"
        "INFO"
        "--rc"
        "--rc-addr"
        ":5572"
        "--rc-no-auth"
        "--attr-timeout"
        "8700h"
        "--umask"
        "002"
        "--cache-dir=/tmp/rclone-grive-cache"
        "--vfs-cache-mode"
        "full"
        "--vfs-cache-max-size"
        "250G"
        "--vfs-cache-max-age"
        "5000h"
        "--vfs-cache-poll-interval"
        "5m"
      ];
      ExecStop = "/run/wrappers/bin/fusermount -u -z %h/Share";
      ExecStartPost = "/run/current-system/sw/bin/rclone rc vfs/refresh recursive=true --rc-addr 127.0.0.1:5572 _async=true";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  xdg.desktopEntries = {
    groove-trainer = {
      name = "Groove Trainer";
      exec = "brave --enable-features=UseOzonePlatform --ozone-platform=wayland --app=\"https://scottsbasslessons.com/groove-trainer\" %U";
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
      exec = "brave --enable-features=UseOzonePlatform --ozone-platform=wayland --app=\"https://app.todoist.com/app/filter/focus-2348004222\" %U";
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
      exec = "brave --enable-features=UseOzonePlatform --ozone-platform=wayland --app=\"https://chatgpt.com/\" %U";
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
  };

}
