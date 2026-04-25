{ inputs, self, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      kitty =
        let
          go_1_26_2 = pkgs.go_1_26.overrideAttrs (
            finalAttrs: previousAttrs: {
              version = "1.26.2";
              src = pkgs.fetchurl {
                url = "https://go.dev/dl/go${finalAttrs.version}.src.tar.gz";
                hash = "sha256-LpHrtpR6lulDb7KzkmqIAu/mOm03Xf/sT4Kqnb1v1Ds=";
              };
              doCheck = false;
              doInstallCheck = false;
            }
          );

          buildGo126Module = pkgs.buildGo126Module.override { go = go_1_26_2; };
        in
        (pkgs.kitty.override {
          buildGo126Module = buildGo126Module;
          go_1_26 = go_1_26_2;
        }).overrideAttrs
          (
            finalAttrs: previousAttrs: {
              pname = "kitty";
              version = "f42a5f89c3a17ef914b4e29168b70dc2fe59fb37";

              src = pkgs.fetchFromGitHub {
                owner = "kovidgoyal";
                repo = "kitty";
                rev = finalAttrs.version;
                hash = "sha256-m8QrxeqIlInoCaj/O7yLQ4Sh1MXTqoDgJVnk29FI5mk=";
              };

              pyproject = false;
              doCheck = false;
              dontCheck = true;
              checkPhase = "true";
              installCheckPhase = "true";

              goModules =
                (buildGo126Module {
                  pname = "kitty-go-modules";
                  src = finalAttrs.src;
                  version = finalAttrs.version;
                  vendorHash = "sha256-jkWijMZrDapttSOrOjKuXLzZI+Lp6BhS1jWbMHJbniI=";
                }).goModules;
            }
          );
    in
    {
      packages = { inherit kitty; };
    };
  m.kitty =
    { pkgs, config, ... }:
    {
      nixpkgs.overlays = [
        (_: prev: {
          kitty = inputs.wrappers.wrappers.kitty.wrap (
            wrapper:
            let
              cfg = config.custom.programs.kitty;
            in
            {
              pkgs = prev;
              package = self.packages.${prev.stdenv.hostPlatform.system}.kitty;
              inherit (cfg) extraConfig keybindings;
              settings = cfg.settings // {
                include = wrapper.config.constructFiles.theme.path;
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
          text_composition_strategy = "legacy";
          font_family = ''family="Maple Mono NF" style="ExtraBold"'';
          bold_font = ''family="Montserrat" style="Black"'';
          italic_font = ''family="Maple Mono NF" style="Bold Italic"'';
          bold_italic_font = ''family="Maple Mono NF" style="ExtraBold Italic"'';
          font_size = "15";
          # font_features = "MapleMono-NL-NF-ExtraBold +zero +onum";
          disable_ligatures = "never";

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
          cursor_shape = "block";
          cursor_blink_interval = "0.5";
          cursor_stop_blinking_after = "15.0";
          enabled_layouts = "splits,stack";

          window_padding_width = "0 1 0 1";

          # Better URL handling
          detect_urls = "yes";
          url_style = "curly";
          # Match foot's "hide cursor when typing"
          mouse_hide_wait = "2.0";

          # Match foot's hollow cursor when unfocused
          focus_follows_mouse = "no"; # if you don't already have FFM
          cursor_shape_unfocused = "hollow"; # kitty 0.36+

          # Use powerline styling
          tab_bar_style = "powerline";
          tab_powerline_style = "round"; # Options: angled, slanted, round

          # --- Tab Naming ---
          tab_title_template = "{index}";
          active_tab_title_template = "{index}";
          # --- Tab Colors (Example: Catppuccin Mocha-ish) ---
          active_tab_foreground = "#1e1e2e";
          active_tab_background = "#c5c0ff";
          active_tab_font_style = "bold-italic";

          inactive_tab_foreground = "#bac2de";
          inactive_tab_background = "#313244";
          inactive_tab_font_style = "normal";

          # Border styling
          window_border_width = "1.5pt";
          active_border_color = "#b4befe"; # A nice pastel highlight
          inactive_border_color = "#45475a"; # Subdued grey for inactive panes

          # Hide the top window title bar on Wayland
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

          # Resize panes
          "ctrl+alt+left" = "resize_window narrower";
          "ctrl+alt+right" = "resize_window wider";
          "ctrl+alt+up" = "resize_window taller";
          "ctrl+alt+down" = "resize_window shorter";
          "ctrl+a>r" = "start_resizing_window";

          # --- Tab Management ---
          # Create a new tab
          "ctrl+a>c" = "new_tab";

          # Switch to specific tabs (1 through 9)
          "ctrl+a>1" = "goto_tab 1";
          "ctrl+a>2" = "goto_tab 2";
          "ctrl+a>3" = "goto_tab 3";
          "ctrl+a>4" = "goto_tab 4";
          "ctrl+a>5" = "goto_tab 5";
          "ctrl+a>6" = "goto_tab 6";
          "ctrl+a>7" = "goto_tab 7";
          "ctrl+a>8" = "goto_tab 8";
          "ctrl+a>9" = "goto_tab 9";
        };
        extraConfig = # toml
          ''
            font_features MapleMono-NF-Bold +cv01 +cv04 +cv05 +cv06 +cv07 +cv08 +cv32 +cv34 +cv36 +cv37 +cv39 +cv40 +cv41 +cv66 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +ss09 +ss10 +ss11 +zero
            font_features MapleMono-NF-ExtraBold +cv01 +cv04 +cv05 +cv06 +cv07 +cv08 +cv32 +cv34 +cv36 +cv37 +cv39 +cv40 +cv41 +cv66 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +ss09 +ss10 +ss11 +zero
            font_features MapleMono-NF-BoldItalic +cv01 +cv04 +cv05 +cv06 +cv07 +cv08 +cv32 +cv34 +cv36 +cv37 +cv39 +cv40 +cv41 +cv66 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +ss09 +ss10 +ss11 +zero
            font_features MapleMono-NF-ExtraBoldItalic +cv01 +cv04 +cv05 +cv06 +cv07 +cv08 +cv32 +cv34 +cv36 +cv37 +cv39 +cv40 +cv41 +cv66 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +ss09 +ss10 +ss11 +zero
            mouse_map right press ungrabbed combine : copy_to_clipboard : clear_selection
            mouse_map left press ungrabbed mouse_selection drag_or_normal_select
          '';
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
