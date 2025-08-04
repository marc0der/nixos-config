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
    protonvpn-cli
    protonvpn-gui
    pywal
    ripgrep
    speedtest-rs
    uv
    vscode
    wlogout
    yamllint
    zsh-powerlevel10k

    # Unstable packages
    unstable.code-cursor
    unstable.claude-code
    claudeDesktop.claude-desktop

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
  };

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
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
