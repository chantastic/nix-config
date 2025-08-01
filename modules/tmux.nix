{ config, lib, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    # shortcut = "a";
    # baseIndex = 1;
    # escapeTime = 0;
    # historyLimit = 10000;
    # keyMode = "vi";
    # mouse = true;
    # newSession = true;
    # terminal = "screen-256color";
    
    # extraConfig = ''
    #   # Enable true color support
    #   set -g default-terminal "screen-256color"
    #   set -ga terminal-overrides ",*256col*:Tc"
    #   
    #   # Better window splitting
    #   bind | split-window -h -c "#{pane_current_path}"
    #   bind - split-window -v -c "#{pane_current_path}"
    #   bind c new-window -c "#{pane_current_path}"
    #   
    #   # Vim-like pane navigation
    #   bind h select-pane -L
    #   bind j select-pane -D
    #   bind k select-pane -U
    #   bind l select-pane -R
    #   
    #   # Resize panes with vim keys
    #   bind -r H resize-pane -L 5
    #   bind -r J resize-pane -D 5
    #   bind -r K resize-pane -U 5
    #   bind -r L resize-pane -R 5
    #   
    #   # Window navigation
    #   bind -r C-h previous-window
    #   bind -r C-l next-window
    #   
    #   # Status bar customization
    #   set -g status-style bg=black,fg=white
    #   set -g window-status-current-style bg=white,fg=black,bold
    #   set -g status-left-length 60
    #   set -g status-right-length 60
    #   set -g status-left "#[fg=green]#H #[fg=black]• #[fg=green,bright]#(uname -r | cut -c 1-6)#[default]"
    #   set -g status-right "#[fg=black]• #[fg=green]#(cut -d ' ' -f 1 /proc/uptime | cut -d '.' -f 1 | sed 's/$/s/') #[fg=black]• #[fg=green]%H:%M#[default]"
    #   
    #   # Start window and pane numbering at 1
    #   set -g base-index 1
    #   setw -g pane-base-index 1
    #   
    #   # Automatically renumber windows
    #   set -g renumber-windows on
    #   
    #   # Increase scrollback buffer
    #   set -g history-limit 10000
    #   
    #   # Focus events enabled for terminal vim
    #   set -g focus-events on
    #   
    #   # Enable clipboard integration on macOS
    #   set -g @plugin 'tmux-plugins/tpm'
    #   set -g @plugin 'tmux-plugins/tmux-sensible'
    #   set -g @plugin 'tmux-plugins/tmux-yank'
    #   
    #   # Yank to system clipboard
    #   set -g @yank_selection_mouse 'clipboard'
    #   
    #   # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
    #   run '~/.tmux/plugins/tpm/tpm'

    # https://www.perplexity.ai/search/folke-tokyo-night-ry7MVpeHRJaB9.lK9le44g
    # set -ag terminal-overrides ",xterm-256color:RGB"

    # chantastic setup
    # set -s escape-time 1

    # setw -g mode-keys vi

    # # reload config
    # bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

    # # # toggle panes
    # # unbind b
    # # bind b select-pane -t :.+

    # # hjkl (vim-like) for pane navigation
    # bind h select-pane -L
    # bind j select-pane -D
    # bind k select-pane -U
    # bind l select-pane -R

    # # HJKL (vim-like) pane resizing
    # bind -r H resize-pane -L 5
    # bind -r J resize-pane -D 5
    # bind -r K resize-pane -U 5
    # bind -r L resize-pane -R 5
    # '';
  };
} 