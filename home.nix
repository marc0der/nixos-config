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

  home.packages = with pkgs; [
    autojump
    bat
    bibata-cursors
    borgbackup
    brave
    bun
    calibre
    chafa
    desktop-file-utils
    devcontainer
    firefox
    fzf
    gh
    ghostty
    htop
    httpie
    jetbrains.idea
    jq
    lazygit
    libsecret
    meld
    mpv
    ncdu
    fastfetch
    nixfmt
    nodejs
    obsidian
    playerctl
    proton-vpn
    (python3.withPackages (ps: [ ps.faster-whisper ]))
    pywal
    ripgrep
    speedtest-rs
    uv
    wl-clipboard
    yamllint
    yq-go
    zsh-powerlevel10k

    # Unstable packages
    llmAgents.claude-code
    llmAgents.codex
    llmAgents.copilot-cli

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
  local.static-assets.enable = true;

  fonts.fontconfig.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  local.session-variables.enable = true;

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/nixos/bin"
    "$HOME/.cargo/bin"
  ];

  programs.home-manager.enable = true;

  xdg.enable = true;

  # Keyring, gpg-agent, and PolKit authentication agent
  local.keyring-services.enable = true;
  local.keyring-services.gpgKeygrip = "B7108ED21D2D31BBA0036C6E7D5D9DCF0DBBA5A6";

  # Google Drive bisync via rclone (staggered 10-minute timer)
  local.google-drive-bisync.enable = true;

  # Brave web-app .desktop launchers
  local.web-app-launchers.enable = true;

  # Claude Code MCP server registration
  local.claude-mcp.enable = true;

}
