{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "marco";
  home.homeDirectory = "/home/marco";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    ansible
    autojump
    bat
    bibata-cursors
    discord
    doctl
    font-manager
    fzf
    gh
    htop
    httpie
    nodePackages.jsonlint
    lazygit
    mpv
    ncdu
    neofetch
    nixfmt-rfc-style
    plexamp
    pywal
    ripgrep
    rustup
    speedtest-rs
    yamllint
    zsh-powerlevel10k

    # themes
    materia-theme
    papirus-icon-theme
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    qt6ct

    # fonts
    font-awesome
    noto-fonts
    noto-fonts-emoji
    jetbrains-mono
    (pkgs.nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "Noto"
      ];
    })
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };
  };

  home.file = {
    ".config/qt5ct/qt5ct.conf".source = qt/qt5ct.conf;
    ".config/qt6ct/qt6ct.conf".source = qt/qt6ct.conf;

    ".gnupg/gpg-agent.conf".source = gnupg/gpg-agent.conf;
    ".gnupg/gpg.conf".source = gnupg/gpg.conf;

    ".config/kitty/kitty.conf".source = kitty/kitty.conf;

    # dunst
    # ".config/dunst/dunstrc".source = dunst/dunstrc;

    # waybar
    # ".config/waybar/config.jsonc".source = waybar/config.jsonc;
    # ".config/waybar/style.css".source = waybar/style.css;

    # kanshi
    # ".config/systemd/user/kanshi.service".source = systemd/kanshi.service;

    ".local/share/applications/todoist.desktop".source = desktop/todoist.desktop;
  };

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
    GTK_THEME = "Materia-dark";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };

  home.sessionPath = [ "$HOME/bin" ];

  home.changes-report.enable = true;

  programs.home-manager.enable = true;
}
