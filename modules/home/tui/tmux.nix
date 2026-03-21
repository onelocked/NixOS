{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    let
      catppuccin-tmux = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "catppuccin-tmux";
        version = "unstable-30-11-23";
        rtpFilePath = "catppuccin.tmux";
        src = pkgs.fetchFromGitHub {
          owner = "omerxx";
          repo = "catppuccin-tmux";
          rev = "e30336b79986e87b1f99e6bd9ec83cffd1da2017";
          hash = "sha256-Ig6+pB8us6YSMHwSRU3sLr9sK+L7kbx2kgxzgmpR920=";
        };
      };
      tmux-floax = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-floax";
        version = "unstable-21-11-24";
        rtpFilePath = "floax.tmux";
        src = pkgs.fetchFromGitHub {
          owner = "omerxx";
          repo = "tmux-floax";
          rev = "3015164722a74716bd1930aacd98201e691f92b1";
          hash = "sha256-TCY3W0/4c4KIsY55uClrlzu90XcK/mgbD58WWu6sPrU=";
        };
      };
      tmuxRun =
        plugin:
        let
          name = plugin.pluginName or (baseNameOf plugin.pname);
          entry = plugin.rtpFilePath or "${name}.tmux";
        in
        # tmux
        ''
          run-shell ${plugin}/share/tmux-plugins/${name}/${entry}
        '';
    in
    {
      programs.tmux = {
        enable = true;
        clock24 = true;
        keyMode = "vi";
        historyLimit = 100000;
        extraConfig = # tmux
          ''
            unbind '['


            bind Space copy-mode
            bind ^C new-window -c "$HOME"
            bind ^D detach
            bind * list-clients
            bind H previous-window
            bind L next-window
            bind r command-prompt "rename-window %%"
            bind ^A last-window
            bind ^W list-windows
            bind w list-windows
            bind z resize-pane -Z
            bind ^L refresh-client
            bind l refresh-client
            bind | split-window
            bind s split-window -v -c "#{pane_current_path}"
            bind v split-window -h -c "#{pane_current_path}"
            bind h select-pane -L
            bind j select-pane -D
            bind k select-pane -U
            bind l select-pane -R
            bind -r -T prefix , resize-pane -L 20
            bind -r -T prefix . resize-pane -R 20
            bind -r -T prefix - resize-pane -D 7
            bind -r -T prefix = resize-pane -U 7
            bind : command-prompt
            bind * setw synchronize-panes
            bind P set pane-border-status
            bind -n C-M-c kill-pane
            bind c new-window -c "#{pane_current_path}"
            bind x swap-pane -D
            bind O choose-session
            bind K send-keys "clear"\; send-keys "Enter"

            set -g allow-passthrough on
            set -ga update-environment TERM
            set -ga update-environment TERM_PROGRAM
            set -g renumber-windows on
            set -g base-index 1
            setw -g pane-base-index 1
            set -g prefix ^A
            set -g detach-on-destroy off
            set -g escape-time 0
            set -g set-clipboard on
            set -g status-position top

            set-option -g default-terminal 'screen-256color'
            set-option -g terminal-overrides ',xterm-256color:RGB'

            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_right_separator " "
            set -g @catppuccin_window_middle_separator " █"
            set -g @catppuccin_window_number_position "right"
            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W"
            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,(),}"
            set -g @catppuccin_status_modules_right "directory date_time"
            set -g @catppuccin_status_modules_left "session"
            set -g @catppuccin_status_left_separator " "
            set -g @catppuccin_status_right_separator " "
            set -g @catppuccin_status_right_separator_inverse "no"
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"
            set -g @catppuccin_directory_text "#{b:pane_current_path}"
            set -g @catppuccin_date_time_text "%H:%M"
            ${tmuxRun catppuccin-tmux}



            set -g @fzf-url-fzf-options '-p 60%,30% --prompt="    " --border-label=" Open URL "'
            set -g @fzf-url-history-limit '2000'
            ${tmuxRun pkgs.tmuxPlugins.tmux-fzf}
            ${tmuxRun pkgs.tmuxPlugins.fzf-tmux-url}

            set -g @floax-width '80%'
            set -g @floax-height '80%'
            set -g @floax-border-color 'white'
            set -g @floax-text-color 'blue'
            set -g @floax-bind 'e'
            set -g @floax-change-path 'true'
            ${tmuxRun tmux-floax}

            set -g @sessionx-bind-zo-new-window 'ctrl-y'
            set -g @sessionx-auto-accept 'off'
            set -g @sessionx-bind 'S'
            set -g @sessionx-window-height '86%'
            set -g @sessionx-window-width '75%'
            set -g @sessionx-zoxide-mode 'on'
            set -g @sessionx-custom-paths-subdirectories 'false'
            set -g @sessionx-filter-current 'false'
            ${tmuxRun pkgs.tmuxPlugins.tmux-sessionx}

            ${tmuxRun pkgs.tmuxPlugins.sensible}
            ${tmuxRun pkgs.tmuxPlugins.yank}
          '';
      };
    };
}
