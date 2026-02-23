{
  flake.homeModules.kitty = {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      settings = {
        include = "./themes/noctalia.conf";

        font_family = "Liga SFMono Semibold";
        bold_font = "Liga SFMono Heavy";
        italic_font = "Liga SFMono Heavy Italic";
        bold_italic_font = "Liga SFMono Heavy Italic";
        font_size = "15";

        adjust_line_height = "0";
        adjust_column_width = "0";

        sync_to_monitor = "yes";
        remember_window_position = "no";

        draw_minimal_borders = "yes";
        window_margin_width = "4";
        placement_strategy = "center";
        update_check_interval = "24";
        allow_hyperlinks = "yes";

        scrollback_lines = "10000";
        wheel_scroll_multiplier = "5.0";

        strip_trailing_spaces = "smart";
        hide_window_decorations = "yes";

        enable_audio_bell = "no";
        visual_bell_duration = "0.0";
        repaint_delay = "10";

        confirm_os_window_close = "0";

        cursor_trail = "1";
        cursor_trail_decay = "0.1 0.2";
        cursor_shape = "beam";
        cursor_blink_interval = "0.5";
        cursor_stop_blinking_after = "15.0";
      };
      extraConfig = # toml
        ''
          mouse_map right press ungrabbed combine : copy_to_clipboard : clear_selection
        '';
    };
  };
}
