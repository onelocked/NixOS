{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    let
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
        terminal = "tmux-256color";
        newSession = false;
        mouse = true;
        prefix = "^A";
        clock24 = true;
        keyMode = "vi";
        historyLimit = 100000;
        extraConfig = # tmux
          ''

            set -g allow-passthrough on
            set -ga update-environment TERM
            set -ga update-environment TERM_PROGRAM
            set -g detach-on-destroy on
            set -g escape-time 0
            set -g set-clipboard on

            set-option -ga terminal-features 'tmux-256color:sixel'
            set-option -g terminal-overrides ',foot*:Tc'

            # pane border color
            set -g pane-border-style "fg=#2a2a2a"
            set -g pane-active-border-style "fg=#2a2a2a"

            #border style
            set -g pane-border-style "fg=#2a2a2a"
            set -g pane-active-border-style "fg=#c5c0ff"

            set -g status-position bottom
            set -g status-style "bg=default,fg=#8fd4b5"
            set -g status-left "#{?client_prefix,  ,  }"
            set -g status-right ""
            set -g status-justify centre

            set -g window-status-format "#[fg=colour238]○ "
            set -g window-status-current-format "#{?window_zoomed_flag,#[fg=#c5c0ff]●  ,#[fg=#c5c0ff]● }"
            set -g window-status-separator "  "

            # keybinds
            unbind '['
            unbind 's'

            #enter vim style copy mode
            bind s copy-mode
            #create a new tab
            bind ^D detach
            bind * list-clients
            bind * setw synchronize-panes
            bind x swap-pane -D
            bind O choose-session
            bind K send-keys "clear"\; send-keys "Enter"

            # fullscreen a pane
            bind -n M-f resize-pane -Z

            # kill pane with Ctrl + X
            bind -n C-x kill-pane


            # Pane movement
            bind -n M-Left  select-pane -L
            bind -n M-Down  select-pane -D
            bind -n M-Up    select-pane -U
            bind -n M-Right select-pane -R


            # create tabs
            bind-key t switch-client -T tab_table
            bind-key -T tab_table n new-window -c "#{pane_current_path}"
            bind c new-window -c "#{pane_current_path}"
            # creating pane splits
            bind-key p switch-client -T pane_table
            bind-key -T pane_table n split-window -h -c "#{pane_current_path}"
            bind-key -T pane_table d split-window -v -c "#{pane_current_path}"
            bind -n C-n split-window -h -c "#{pane_current_path}"

            bind-key r switch-client -T resize_table
            bind-key -T resize_table Left  resize-pane -L 5 \; switch-client -T resize_table
            bind-key -T resize_table Right resize-pane -R 5 \; switch-client -T resize_table
            bind-key -T resize_table Up    resize-pane -U 5 \; switch-client -T resize_table
            bind-key -T resize_table Down  resize-pane -D 5 \; switch-client -T resize_table
            bind-key -T resize_table Escape switch-client -T root



            # SessionX Plugin
            set -g @sessionx-auto-accept 'off'
            set -g @sessionx-window-height '86%'
            set -g @sessionx-window-width '75%'
            set -g @sessionx-zoxide-mode 'on'
            set -g @sessionx-custom-paths-subdirectories 'false'
            set -g @sessionx-filter-current 'false'
            # Assign the default to a dummy key so it stops stealing <Leader> + O
            set -g @sessionx-bind 'M-F12'
            bind-key o switch-client -T sessionx_table
            bind-key -T sessionx_table w run-shell "${pkgs.tmuxPlugins.tmux-sessionx}/share/tmux-plugins/sessionx/scripts/sessionx.sh"

            ${tmuxRun pkgs.tmuxPlugins.tmux-sessionx}

            # Floax plugin
            set -g @floax-width '80%'
            set -g @floax-height '80%'
            set -g @floax-border-color 'white'
            set -g @floax-text-color 'blue'
            set -g @floax-change-path 'true'
            # Bind Floax to use Ctrl+F
            set -g @floax-bind '-n C-f'
            ${tmuxRun tmux-floax}

            ${tmuxRun pkgs.tmuxPlugins.sensible}
            ${tmuxRun pkgs.tmuxPlugins.yank}

            set -g base-index 1
            setw -g pane-base-index 1
            set -g renumber-windows on
          '';
      };
    };
}
