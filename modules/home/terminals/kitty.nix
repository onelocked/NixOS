{ inputs, ... }:
{
  m.kitty =
    { pkgs, config, ... }:
    let
      cfg = config.custom.programs.kitty;
    in
    {
      nixpkgs.overlays = [
        (_: prev: {
          kitty = inputs.wrappers.wrappers.kitty.wrap (
            { config, ... }:
            {
              pkgs = prev;
              inherit (cfg) extraConfig keybindings;
              settings = cfg.settings // {
                include = config.constructFiles.theme.path;
              };
              constructFiles.theme = {
                relPath = "oneshill.conf";
                content = cfg.theme;
              };
            }
          );
        })
      ];
      hj.packages = [ pkgs.kitty ];
      custom.programs.kitty = {
        settings = {
          text_composition_strategy = "legacy"; # fix blurry font
          font_family = "family='Maple Mono NL NF' style=ExtraBold";
          bold_font = "family='LigaSFMono Nerd Font' style=Heavy";
          italic_font = "family='LigaSFMono Nerd Font' style='Bold Italic'";
          bold_italic_font = "family='LigaSFMono Nerd Font' style='Heavy Italic'";
          font_size = "15";
          # font_features = "MapleMono-NL-NF-ExtraBold +zero +onum";

          wayland_enable_ime = "no";

          sync_to_monitor = "yes";
          remember_window_position = "no";

          draw_minimal_borders = "yes";
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
          enabled_layouts = "splits,stack";

          window_padding_width = "0 3 0 3";

          # Better URL handling
          detect_urls = "yes";
          url_style = "curly";
          # Match foot's "hide cursor when typing"
          mouse_hide_wait = "2.0";

          # Match foot's hollow cursor when unfocused
          focus_follows_mouse = "no"; # if you don't already have FFM
          cursor_shape_unfocused = "hollow"; # kitty 0.36+
        };
        keybindings = {
          # Splits
          "ctrl+a>p>d" = "launch --location=hsplit";
          "ctrl+a>p>n" = "launch --location=vsplit";
          "ctrl+n" = "launch --location=vsplit";
          # Navigation with Alt + arrows
          "alt+left" = "neighboring_window left";
          "alt+right" = "neighboring_window right";
          "alt+up" = "neighboring_window up";
          "alt+down" = "neighboring_window down";

          "ctrl+x" = "close_window";
        };
        extraConfig = # toml
          "mouse_map right press ungrabbed combine : copy_to_clipboard : clear_selection ";
        theme = # bash
          ''
            color0  #131316
            color1  #ffb4ab
            color2  #a6e3a1
            color3  #d4b483
            color4  #c5c0ff
            color5  #e4a8d4
            color6  #6fbac2
            color7  #c8c5d0
            color8  #6f6d78
            color9  #ffcbc2
            color10 #c1ecbd
            color11 #e5cfa8
            color12 #dcd8ff
            color13 #f0c4e4
            color14 #b5e5e9
            color15 #e5e1e6

            background            #131316
            foreground            #e5e1e6

            cursor                #c5c0ff
            cursor_text_color     #131316
            cursor_trail_color    #c5c0ff

            selection_background  #c5c0ff
            selection_foreground  #131316

            active_border_color   #c5c0ff
            inactive_border_color #47464f

            url_color             #a89cc7

            active_tab_foreground   #131316
            active_tab_background   #c5c0ff
            inactive_tab_foreground #c8c5d0
            inactive_tab_background #2a2932
          '';
      };
    };
  m.default =
    { lib, ... }:
    let
      inherit (lib)
        types
        mkOption
        literalExpression
        ;

      settingsValueType =
        with types;
        oneOf [
          str
          bool
          int
          float
        ];
    in
    {
      options.custom.programs.kitty = {
        settings = mkOption {
          type = types.attrsOf settingsValueType;
          default = { };
          example = literalExpression ''
            {
              scrollback_lines = 10000;
              enable_audio_bell = false;
              update_check_interval = 0;
            }
          '';
          description = ''
            Key/value pairs written into `kitty.conf`.
            See <https://sw.kovidgoyal.net/kitty/conf.html>.
          '';
        };
        theme = mkOption {
          type = with lib.types; nullOr (either path lines);
          default = "";
          description = ''
            Color scheme for kitty
          '';
        };

        keybindings = mkOption {
          type = types.attrsOf types.str;
          default = { };
          example = literalExpression ''
            {
              "ctrl+c" = "copy_or_interrupt";
              "ctrl+f>2" = "set_font_size 20";
            }
          '';
          description = "Mapping of keybindings to actions.";
        };

        extraConfig = mkOption {
          type = types.lines;
          default = "";
          description = "Additional configuration appended verbatim to kitty.conf.";
        };
      };
    };
}
