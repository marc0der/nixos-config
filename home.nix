{
  config,
  pkgs,
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
    rclone
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
    ".local/share/applications/todoist.desktop".source = desktop/todoist.desktop;
    ".local/share/applications/chatgpt.desktop".source = desktop/chatgpt.desktop;
    ".local/share/icons/chatgpt.png".source = icons/chatgpt.png;
  };

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
  };

  home.sessionPath = [ "$HOME/bin" ];

  home.changes-report.enable = true;

  programs.home-manager.enable = true;

}
