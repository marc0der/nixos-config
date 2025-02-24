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
    cliphist
    discord
    doctl
    font-manager
    fzf
    gh
    grim
    htop
    httpie
    jq
    nodePackages.jsonlint
    lazygit
    meld
    mpv
    ncdu
    neofetch
    nixfmt-rfc-style
    obsidian
    plexamp
    pywal
    ripgrep
    rofi
    rustup
    slurp
    speedtest-rs
    swaynotificationcenter
    waybar
    wl-clipboard
    wlogout
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

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

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
    GTK_THEME = "Materia-dark";
    POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
  };

  home.sessionPath = [ "$HOME/bin" ];

  home.changes-report.enable = true;

  programs.home-manager.enable = true;

}
