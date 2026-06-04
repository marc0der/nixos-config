{
  pkgs,
  llmAgents,
  ...
}:

{

  home.username = "marco";
  home.homeDirectory = "/home/marco";
  # Pinned to original install (24.11); deliberately not bumped with channel.
  home.stateVersion = "24.11";

  desktop-common.enable = true;

  home.packages = with pkgs; [
    autojump
    bat
    bibata-cursors
    borgbackup
    brave
    bun
    chafa
    cliphist
    devcontainer
    eog
    evince
    file-roller
    firefox
    font-manager
    fzf
    gedit
    gh
    ghostty
    gnome-calculator
    htop
    httpie
    jetbrains.idea
    jq
    kanshi
    lazygit
    meld
    mpv
    nautilus
    ncdu
    fastfetch
    nixfmt
    nodejs
    obsidian
    pinentry-gnome3
    polkit_gnome
    proton-vpn
    (python3.withPackages (ps: [ ps.faster-whisper ]))
    pywal
    ripgrep
    speedtest-rs
    uv
    vscode
    wl-mirror
    wlogout
    yamllint
    zsh-powerlevel10k

    # Unstable packages
    llmAgents.claude-code
    llmAgents.codex
    llmAgents.copilot-cli
    llmAgents.pi

    # Shared themes
    materia-theme
    papirus-icon-theme
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qt6ct

    # fonts
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
    fira-code
    fira-code-symbols
    fira-sans
    jetbrains-mono
    # Nerd fonts (NixOS 25.05+ format)
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.noto
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.symbols-only
  ];

  # Static dotfile assets (gnupg, qt, icons, claude)
  static-assets.enable = true;

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

  session-variables.enable = true;

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/nixos/bin"
    "$HOME/.cargo/bin"
  ];

  programs.home-manager.enable = true;

  xdg.enable = true;

  # Keyring, gpg-agent, and PolKit authentication agent
  keyring-services.enable = true;

  # Google Drive bisync via rclone (staggered 10-minute timer)
  google-drive-bisync.enable = true;

  # Brave web-app .desktop launchers
  web-app-launchers.enable = true;

  # Claude Code MCP server registration
  claude-mcp.enable = true;

}
