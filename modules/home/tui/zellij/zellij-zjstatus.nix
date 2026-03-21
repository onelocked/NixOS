{
  flake.modules.homeManager.zellij =
    { pkgs, ... }:
    let
      zjstatus = pkgs.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
        sha256 = "sha256-TeQm0gscv4YScuknrutbSdksF/Diu50XP4W/fwFU3VM=";
      };
    in
    {
      programs.zellij =
        let
          zjstatusPlugin = # kdl
            ''
              pane size=1 borderless=true {
                plugin location="file:${zjstatus}" {
                  hide_frame_for_single_pane "false"
                  hide_frame_except_for_search     "false"
                  hide_frame_except_for_scroll     "false"
                  hide_frame_except_for_fullscreen "false"

                  border_enabled  "false"
                  border_char     "─"
                  border_format   "#[fg=#6C7086]{char}"
                  border_position "top"

                  format_left   "{mode}"
                  format_center "{tabs}"
                  format_right  ""
                  format_space  ""


                  // indicators
                  tab_sync_indicator       "<> "
                  tab_fullscreen_indicator " "
                  tab_floating_indicator   "⬚ "

                  // Modes
                  mode_normal        "#[fg=#8fd4b5,bg=#131316]  "
                  mode_locked        "#[fg=#f4a8b8,bg=#131316]  "
                  mode_resize        "#[fg=#d4a8c0,bg=#131316] 󰩨 "
                  mode_pane          "#[fg=#7d75c0,bg=#131316]  "
                  mode_tab           "#[fg=#f2b8a0,bg=#131316] 󱦞 "
                  mode_scroll        "#[fg=#c8b0e8,bg=#131316]  "
                  mode_session       "#[fg=#f6d88a,bg=#131316] 󰍻  "
                  mode_move          "#[fg=#e8c4d8,bg=#131316]  "


                  // inactive tabs
                  tab_normal              "#[fg=#c5c0ff] ○ "
                  tab_normal_fullscreen   "#[fg=#c5c0ff] ○ "
                  tab_normal_sync         "#[fg=#c5c0ff] ○ "

                  // formatting for the current active tab
                  tab_active              "#[fg=#7d75c0,bg=#131316,bold] {floating_indicator}● "
                  tab_active_fullscreen   "#[fg=#7d75c0,bg=#131316,bold] {fullscreen_indicator}● "
                  tab_active_sync         "#[fg=#7d75c0,bg=#131316,bold] {sync_indicator}● "

                  tab_separator           ""
                  // format when renaming a tab
                  tab_rename              "#[bg=#d699b6,fg=#272e33] {index} {name} {floating_indicator} "

                  // limit tab display count
                  tab_display_count         "5"  // limit number of visible tabs
                  tab_truncate_start_format "#[fg=#dbbc7f]#[fg=#272e33,bg=#dbbc7f]+{count} "
                  tab_truncate_end_format   "#[fg=#272e33,bg=#dbbc7f] +{count}#[fg=#dbbc7f]"
                }
              }
            '';

          defaultTabTemplate = # kdl
            ''
              default_tab_template {
                children
                ${zjstatusPlugin}
              }
              swap_floating_layout {
                floating_panes max_panes=1 {
                  pane {
                    x "10%"
                    y "10%"
                    width "80%"
                    height "80%"
                  }
                }
                floating_panes {
                  pane {
                    x "10%"
                    y "10%"
                    width "80%"
                    height "80%"
                  }
                }
              }
            '';
          defaultLayout =
            pkgs.writeText "defaultLayout.kdl" # kdl
              ''
                layout {
                  ${defaultTabTemplate}
                }
              '';
        in
        {
          settings = {
            default_layout = "${defaultLayout}";
          };
        };
    };
}
