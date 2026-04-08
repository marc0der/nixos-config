{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    # Core behavior
    prefix = "C-Space";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 50000;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      # True color and undercurl support
      set -ga terminal-overrides ',*256col*:Tc'
      set -ga terminal-overrides ',xterm-256color:Tc'
      set -as terminal-features ',xterm-256color:RGB'

      # Pane base index matches window base index
      setw -g pane-base-index 1

      # Renumber windows when one is closed so the list stays tidy
      set -g renumber-windows on

      # Focus events for vim/neovim autoread
      set -g focus-events on

      # Intuitive splits that open in the current pane's working dir
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # New windows also open in the current path
      bind c new-window -c "#{pane_current_path}"

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Vim-style pane resizing (repeatable with -r)
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Quick config reload
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"

      # Vi-style copy mode bindings
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      #
      # Powerline-style status bar
      #
      # Colors use the terminal's ANSI palette (default, black/red/green/...,
      # brightblack/...), so any palette tool that remaps the 16 ANSI slots
      # — pywal, base16, the terminal theme — will automatically restyle this
      # bar without touching tmux config.
      #
      # Glyphs use Powerline / Nerd Font codepoints (U+E0B0 / U+E0B2). You
      # need a Nerd Font (you have nerd-fonts.jetbrains-mono installed).
      #
      # Make pane bodies transparent so the terminal background shows through
      set -g window-style 'fg=terminal,bg=terminal'
      set -g window-active-style 'fg=terminal,bg=terminal'

      set -g status-position top
      set -g status-interval 5
      set -g status-justify left

      set -g status-style 'bg=terminal,fg=terminal'
      set -g status-left-length 100
      set -g status-right-length 150

      # Left: session name on a blue powerline segment
      set -g status-left '#[fg=black,bg=blue,bold] #S #[fg=blue,bg=terminal,nobold] '

      # Right: optional PREFIX indicator, then date segment, then time segment
      set -g status-right '#{?client_prefix,#[fg=red#,bg=terminal]#[fg=black#,bg=red#,bold] PREFIX #[fg=brightblack#,bg=red],#[fg=brightblack#,bg=terminal]}#[fg=terminal,bg=brightblack] %Y-%m-%d #[fg=blue,bg=brightblack]#[fg=black,bg=blue,bold] %H:%M '

      # Window list — current window highlighted in magenta
      setw -g window-status-separator '''
      setw -g window-status-format '#[fg=terminal,bg=terminal] #I  #W '
      setw -g window-status-current-format '#[fg=magenta,bg=terminal]#[fg=black,bg=magenta,bold] #I  #W #[fg=magenta,bg=terminal]'

      # Pane borders
      set -g pane-border-style 'fg=brightblack'
      set -g pane-active-border-style 'fg=blue'

      # Message / command line
      set -g message-style 'bg=blue,fg=black,bold'
      set -g message-command-style 'bg=blue,fg=black,bold'

      # Mode (copy/selection) style
      setw -g mode-style 'bg=magenta,fg=black,bold'

      # Activity bell
      setw -g monitor-activity on
      set -g visual-activity off
    '';
  };
}
