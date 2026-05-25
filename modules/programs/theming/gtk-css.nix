{
  m.default = {
    custom.gtk.theme.css = # css
      ''
        @define-color accent_color #c5c0ff;
        @define-color accent_bg_color #c5c0ff;
        @define-color accent_fg_color #2a2277;

        @define-color destructive_bg_color #ffb4ab;
        @define-color destructive_fg_color #690005;

        @define-color error_bg_color #ffb4ab;
        @define-color error_fg_color #690005;

        @define-color window_bg_color #131316;
        @define-color window_fg_color #e5e1e6;

        @define-color view_bg_color #131316;
        @define-color view_fg_color #e5e1e6;

        @define-color headerbar_bg_color #131316;
        @define-color headerbar_fg_color #e5e1e6;
        @define-color headerbar_backdrop_color @window_bg_color;

        @define-color popover_bg_color #201f23;
        @define-color popover_fg_color #e5e1e6;

        @define-color card_bg_color #201f23;
        @define-color card_fg_color #e5e1e6;

        @define-color dialog_bg_color #131316;
        @define-color dialog_fg_color #e5e1e6;

        @define-color overview_bg_color #201f23;
        @define-color overview_fg_color #e5e1e6;

        @define-color sidebar_bg_color #201f23;
        @define-color sidebar_fg_color #e5e1e6;
        @define-color sidebar_backdrop_color @window_bg_color;
        @define-color sidebar_border_color @window_bg_color;

        @define-color secondary_sidebar_bg_color #131316;
        @define-color secondary_sidebar_fg_color #e5e1e6;

        /* Backdrop/unfocused states */
        @define-color theme_unfocused_fg_color @window_fg_color;
        @define-color theme_unfocused_text_color @view_fg_color;
        @define-color theme_unfocused_bg_color @window_bg_color;
        @define-color theme_unfocused_base_color @window_bg_color;
        @define-color theme_unfocused_selected_bg_color @accent_bg_color;
        @define-color theme_unfocused_selected_fg_color @accent_fg_color;

        :root {
            --accent-color: #c5c0ff;
            --accent-bg-color: #c5c0ff;
            --accent-fg-color: #2a2277;

            --destructive-bg-color: #ffb4ab;
            --destructive-fg-color: #690005;

            --error-bg-color: #ffb4ab;
            --error-fg-color: #690005;
            --error-color: #ffb4ab;

            --window-bg-color: #131316;
            --window-fg-color: #e5e1e6;

            --view-bg-color: #131316;
            --view-fg-color: #e5e1e6;

            --headerbar-bg-color: #131316;
            --headerbar-fg-color: #e5e1e6;
            --headerbar-backdrop-color: @window_bg_color;

            --popover-bg-color: #201f23;
            --popover-fg-color: #e5e1e6;

            --card-bg-color: #201f23;
            --card-fg-color: #e5e1e6;

            --dialog-bg-color: #131316;
            --dialog-fg-color: #e5e1e6;

            --overview-bg-color: #201f23;
            --overview-fg-color: #e5e1e6;

            --sidebar-bg-color: #201f23;
            --sidebar-fg-color: #e5e1e6;
            --sidebar-backdrop-color: @window_bg_color;
            --sidebar-border-color: @window_bg_color;

            --warning-bg-color: #603b4f;
            --warning-fg-color: #ffd8e9;
            --warning-color: #ebb9d0;

            --success-color: #c7c4dc;
            --success-bg-color: #464559;
            --success-fg-color: #e4dff9;

            --shade-color: rgba(0, 0, 0, 0.36);
        }
      '';
  };
}
