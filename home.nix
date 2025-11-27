{
  config,
  lib,
  pkgs,
  claudeDesktop,
  unstable,
  ...
}:

{

  home.username = "marco";
  home.homeDirectory = "/home/marco";
  home.stateVersion = "24.11";

  desktop-common.enable = true;

  home.packages = with pkgs; [
    autojump
    bat
    bibata-cursors
    borgbackup
    brave
    chafa
    cliphist
    eog
    evince
    file-roller
    font-manager
    fzf
    gedit
    gh
    ghostty
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
    nixfmt-rfc-style
    nodejs
    nodePackages.jsonlint
    obsidian
    pinentry-gnome3
    polkit_gnome
    protonvpn-cli
    protonvpn-gui
    python3
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
    # Nerd fonts (NixOS 25.05+ format)
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.noto
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.symbols-only
  ];

  home.file = {
    ".gnupg/gpg.conf".source = gnupg/gpg.conf;
    ".config/qt5ct/qt5ct.conf".source = qt/qt5ct.conf;
    ".config/qt6ct/qt6ct.conf".source = qt/qt6ct.conf;
    ".local/share/icons/chatgpt.png".source = icons/chatgpt.png;
    ".local/share/icons/claude-desktop.png".source = icons/claude-desktop.png;
    ".claude/agents/git-guy.md".source = claude/agents/git-guy.md;
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

  session-variables.enable = true;

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/nixos/bin"
  ];

  home.changes-report.enable = true;

  programs.home-manager.enable = true;

  xdg.enable = true;

  services.gnome-keyring = {
    enable = true;
    components = [
      "pkcs11"
      "secrets"
    ];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 31536000; # 1 year
    maxCacheTtl = 31536000;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "GNOME Polkit Authentication Agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.google-drive-bisync = {
    Unit = {
      Description = "Google Drive bisync service";
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      Environment = [
        "RCLONE_CONFIG=%h/.config/rclone/rclone.conf"
        "PATH=/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:%h/.nix-profile/bin"
      ];
      ExecStartPre = "${pkgs.writeShellScript "log-sync-start" ''
        HOSTNAME=$(${pkgs.nettools}/bin/hostname)
        if [[ "$HOSTNAME" == "neomorph" ]]; then
          SCHEDULE=":00,:10,:20,:30,:40,:50"
        else
          SCHEDULE=":05,:15,:25,:35,:45,:55"
        fi
        echo "Starting GoogleDrive sync on $HOSTNAME (schedule: $SCHEDULE)"
      ''}";
      ExecStart = toString [
        "/run/current-system/sw/bin/rclone"
        "bisync"
        "drive:Share"
        "%h/GoogleDrive"
        "--resilient"
        "--create-empty-src-dirs"
        "--conflict-resolve=newer"
        "--log-file"
        "/tmp/rclone-bisync.log"
        "--log-level"
        "INFO"
      ];
      ExecStartPost = "${pkgs.writeShellScript "log-sync-end" ''
        HOSTNAME=$(${pkgs.nettools}/bin/hostname)
        echo "Completed GoogleDrive sync on $HOSTNAME"
      ''}";
    };
  };

  systemd.user.timers.google-drive-bisync =
    let
      # Staggered timing: neomorph syncs at :00,:10,:20 etc, xenomorph at :05,:15,:25 etc
      hostname = config.networking.hostName or "unknown";
      syncSchedule = if hostname == "neomorph" then "*:00/10" else "*:05/10";
    in
    {
      Unit = {
        Description = "Run Google Drive bisync every 10 minutes (staggered)";
      };

      Timer = {
        OnBootSec = if hostname == "neomorph" then "2min" else "7min";
        OnCalendar = syncSchedule;
        Unit = "google-drive-bisync.service";
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
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

  home.activation.setupClaudeMcpServers = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    echo "Configuring Claude MCP servers..."

    # Source secrets file if it exists
    [[ -f ~/.config/secrets/env ]] && source ~/.config/secrets/env

    # Use the full path to claude from the nix store
    CLAUDE_BIN="${unstable.claude-code}/bin/claude"

    # Configure git-mcp server
    if ! "$CLAUDE_BIN" mcp get git-mcp >/dev/null 2>&1; then
      echo "Adding git-mcp server..."
      "$CLAUDE_BIN" mcp add git-mcp -s user uvx mcp-server-git || echo "Failed to add git-mcp server"
    fi

    # Configure github-mcp server with environment variable
    if ! "$CLAUDE_BIN" mcp get github-mcp >/dev/null 2>&1; then
      echo "Adding github-mcp server..."
      if [[ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]]; then
        echo "Warning: GITHUB_PERSONAL_ACCESS_TOKEN environment variable not set"
        echo "Please set it in your shell profile or environment"
      else
        "$CLAUDE_BIN" mcp add github-mcp -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" -s user npx @modelcontextprotocol/server-github || echo "Failed to add github-mcp server"
      fi
    fi

    echo "Claude MCP servers configured"
  '';

}
