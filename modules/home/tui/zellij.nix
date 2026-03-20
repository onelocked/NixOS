{
  flake.modules.homeManager.zellij =
    { pkgs, ... }:
    let
      zjstatus = pkgs.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
        sha256 = "sha256-TeQm0gscv4YScuknrutbSdksF/Diu50XP4W/fwFU3VM=";
      };
      zjstatus-hints = pkgs.fetchurl {
        url = "https://github.com/b0o/zjstatus-hints/releases/download/v0.1.4/zjstatus-hints.wasm";
        sha256 = "sha256-k2xV6QJcDtvUNCE4PvwVG9/ceOkk+Wa/6efGgr7IcZ0=";
      };
    in
    {
      programs.zellij =
        let
          zjstatusPlugin = # kdl
            ''
              pane size=1 borderless=true {
                plugin location="file:${zjstatus}" {
                  hide_frame_for_single_pane "true"
                  hide_frame_except_for_search     "false"
                  hide_frame_except_for_scroll     "false"
                  hide_frame_except_for_fullscreen "false"

                  border_enabled  "false"
                  border_char     "─"
                  border_format   "#[fg=#6C7086]{char}"
                  border_position "top"

                  format_left   "{mode}"
                  format_center "{tabs}"
                  format_right  "{pipe_zjstatus_hints}"
                  format_space  ""

                  // NOTE: this is necessary for the zjstatus-hint plugin to render
                  pipe_zjstatus_hints_format "{output}"

                  // indicators
                  tab_sync_indicator       "<> "
                  tab_fullscreen_indicator " "
                  tab_floating_indicator   "⬚ "

                  // Modes
                  mode_normal        "#[fg=#272e33,bg=#a7c080,bold]  "
                  mode_locked        "#[fg=#272e33,bg=#e67e80,bold]  "
                  mode_resize        "#[fg=#272e33,bg=#dbbc7f,bold] 󰩨 "
                  mode_pane          "#[fg=#272e33,bg=#d699b6,bold]  "
                  mode_tab           "#[fg=#272e33,bg=#7fbbb3,bold] 󱦞 "
                  mode_scroll        "#[fg=#272e33,bg=#83c092,bold]  "
                  mode_session       "#[fg=#272e33,bg=#e69875,bold] 󰍻  "
                  mode_move          "#[fg=#272e33,bg=#9da9a0,bold]  "


                  // inactive tabs
                  tab_normal              "#[fg=#859289] ○ {floating_indicator}"
                  tab_normal_fullscreen   "#[fg=#859289] ○ {fullscreen_indicator}"
                  tab_normal_sync         "#[fg=#859289] ○ {sync_indicator}"

                  // formatting for the current active tab
                  tab_active              "#[fg=#272e33,bg=#7fbbb3,bold] ● {floating_indicator}"
                  tab_active_fullscreen   "#[fg=#272e33,bg=#7fbbb3,bold] ● {fullscreen_indicator}"
                  tab_active_sync         "#[fg=#272e33,bg=#7fbbb3,bold] ● {sync_indicator}"

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

          lazygitLayout =
            pkgs.writeText "lazygit.kdl" # kdl
              ''
                layout {
                  pane name="lazygit" {
                    command "${pkgs.lazygit}/bin/lazygit"
                    close_on_exit true
                  }
                }
              '';
          sysmonLayout =
            pkgs.writeText "sysmon.kdl" # kdl
              ''
                layout {
                  ${defaultTabTemplate}
                  tab name="sysmon" {
                    pane split_direction="vertical" {
                      pane size="70%" name="btop" {
                        command "${pkgs.btop-rocm}/bin/btop"
                        close_on_exit true
                      }
                      pane size="30%" name="amdgpu" {
                        command "${pkgs.amdgpu_top}/bin/amdgpu_top"
                        args "--dark"
                        close_on_exit true
                      }
                    }
                  }
                }
              '';
          theme =
            pkgs.writeTextDir "mocha.kdl" # kdl
              ''
                themes {
                    mocha {
                        text_unselected {
                            base 207 211 231
                            background 30 30 46
                            emphasis_0 242 184 160
                            emphasis_1 124 184 212
                            emphasis_2 184 219 140
                            emphasis_3 200 176 232
                        }
                        text_selected {
                            base 207 211 231
                            background 69 69 69
                            emphasis_0 242 184 160
                            emphasis_1 124 184 212
                            emphasis_2 184 219 140
                            emphasis_3 200 176 232
                        }
                        ribbon_selected {
                            base 30 30 46
                            background 197 192 255
                            emphasis_0 168 200 240
                            emphasis_1 242 184 160
                            emphasis_2 200 176 232
                            emphasis_3 124 184 212
                        }
                        ribbon_unselected {
                            base 30 30 46
                            background 207 211 231
                            emphasis_0 168 200 240
                            emphasis_1 207 211 231
                            emphasis_2 197 192 255
                            emphasis_3 200 176 232
                        }
                        table_title {
                            base 197 192 255
                            background 0
                            emphasis_0 242 184 160
                            emphasis_1 124 184 212
                            emphasis_2 184 219 140
                            emphasis_3 200 176 232
                        }
                        table_cell_selected {
                            base 207 211 231
                            background 69 69 69
                            emphasis_0 242 184 160
                            emphasis_1 124 184 212
                            emphasis_2 184 219 140
                            emphasis_3 200 176 232
                        }
                        table_cell_unselected {
                            base 207 211 231
                            background 30 30 46
                            emphasis_0 242 184 160
                            emphasis_1 124 184 212
                            emphasis_2 184 219 140
                            emphasis_3 200 176 232
                        }
                        list_selected {
                            base 207 211 231
                            background 69 69 69
                            emphasis_0 242 184 160
                            emphasis_1 124 184 212
                            emphasis_2 184 219 140
                            emphasis_3 200 176 232
                        }
                        list_unselected {
                            base 207 211 231
                            background 30 30 46
                            emphasis_0 242 184 160
                            emphasis_1 124 184 212
                            emphasis_2 184 219 140
                            emphasis_3 200 176 232
                        }
                        frame_selected {
                            base 53 53 67     // s
                            background 0
                            emphasis_0 242 184 160
                            emphasis_1 197 192 255
                            emphasis_2 200 176 232
                            emphasis_3 0
                        }
                        frame_unselected {
                            base 19 19 22     // s
                            background 0
                            emphasis_0 242 184 160
                            emphasis_1 197 192 255
                            emphasis_2 200 176 232
                            emphasis_3 0
                        }

                        frame_highlight {
                            base 197 192 255
                            background 0
                            emphasis_0 200 176 232
                            emphasis_1 197 192 255
                            emphasis_2 168 200 240
                            emphasis_3 197 192 255
                        }
                        exit_code_success {
                            base 184 219 140
                            background 0
                            emphasis_0 143 212 181
                            emphasis_1 30 30 46
                            emphasis_2 200 176 232
                            emphasis_3 197 192 255
                        }
                        exit_code_error {
                            base 255 122 107
                            background 0
                            emphasis_0 246 216 138
                            emphasis_1 0
                            emphasis_2 0
                            emphasis_3 0
                        }
                        multiplayer_user_colors {
                            player_1 200 176 232
                            player_2 168 200 240
                            player_3 0
                            player_4 246 216 138
                            player_5 124 184 212
                            player_6 0
                            player_7 255 122 107
                            player_8 0
                            player_9 0
                            player_10 0
                        }
                    }
                }
              '';
        in
        {
          enable = true;
          extraConfig = # kdl
            ''
              default_layout "${defaultLayout}"

              session_serialization false

              ui {
                  pane_frames {
                      hide_session_name true
                      rounded_corners true
                  }
              }
              theme "mocha";
              theme_dir "${theme}";
              default_mode "locked"
              mouse_mode true
              advanced_mouse_actions false
              copy_command "${pkgs.wl-clipboard-rs}/bin/wl-copy"
              copy_on_select true
              Default: false
              show_startup_tips false
              pane_frames false

              plugins {
                  zjstatus-hints location="file:${zjstatus-hints}" {
                      max_length 100 // 0 = unlimited
                      overflow_str "..." // default
                      pipe_name "zjstatus_hints" // default
                      hide_in_base_mode true
                  }
              }
              load_plugins {
                  zjstatus-hints
              }

              keybinds clear-defaults=true {
                  locked {
                      bind "Ctrl a" { SwitchToMode "normal"; }
                  }
                  normal {
                      bind "1" { GoToTab 1; SwitchToMode "locked"; }
                      bind "2" { GoToTab 2; SwitchToMode "locked"; }
                      bind "3" { GoToTab 3; SwitchToMode "locked"; }
                      bind "4" { GoToTab 4; SwitchToMode "locked"; }
                      bind "5" { GoToTab 5; SwitchToMode "locked"; }
                      bind "6" { GoToTab 6; SwitchToMode "locked"; }
                      bind "7" { GoToTab 7; SwitchToMode "locked"; }
                      bind "8" { GoToTab 8; SwitchToMode "locked"; }
                      bind "9" { GoToTab 9; SwitchToMode "locked"; }
                      bind "c" { NewTab; SwitchToMode "locked"; }
                      bind "left" { MoveTab "left";  }
                      bind "right" { MoveTab "right";  }
                }
                  pane {
                      bind "left" { MoveFocus "left"; }
                      bind "down" { MoveFocus "down"; }
                      bind "up" { MoveFocus "up"; }
                      bind "right" { MoveFocus "right"; }
                      bind "c" { SwitchToMode "renamepane"; PaneNameInput 0; }
                      bind "d" { NewPane "down"; SwitchToMode "locked"; }
                      bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "locked"; }
                      bind "f" { ToggleFocusFullscreen; SwitchToMode "locked"; }
                      bind "h" { MoveFocus "left"; }
                      bind "i" { TogglePanePinned; SwitchToMode "locked"; }
                      bind "j" { MoveFocus "down"; }
                      bind "k" { MoveFocus "up"; }
                      bind "l" { MoveFocus "right"; }
                      bind "n" { NewPane; SwitchToMode "locked"; }
                      bind "p" { SwitchToMode "normal"; }
                      bind "r" { NewPane "right"; SwitchToMode "locked"; }
                      bind "s" { NewPane "stacked"; SwitchToMode "locked"; }
                      bind "w" { ToggleFloatingPanes; SwitchToMode "locked"; }
                      bind "x" { CloseFocus; SwitchToMode "locked"; }
                      bind "z" { TogglePaneFrames; SwitchToMode "locked"; }
                      bind "tab" { SwitchFocus; }
                  }
                  tab {
                      bind "left" { GoToPreviousTab; }
                      bind "down" { GoToNextTab; }
                      bind "up" { GoToPreviousTab; }
                      bind "right" { GoToNextTab; }
                      bind "1" { GoToTab 1; SwitchToMode "locked"; }
                      bind "2" { GoToTab 2; SwitchToMode "locked"; }
                      bind "3" { GoToTab 3; SwitchToMode "locked"; }
                      bind "4" { GoToTab 4; SwitchToMode "locked"; }
                      bind "5" { GoToTab 5; SwitchToMode "locked"; }
                      bind "6" { GoToTab 6; SwitchToMode "locked"; }
                      bind "7" { GoToTab 7; SwitchToMode "locked"; }
                      bind "8" { GoToTab 8; SwitchToMode "locked"; }
                      bind "9" { GoToTab 9; SwitchToMode "locked"; }
                      bind "[" { BreakPaneLeft; SwitchToMode "locked"; }
                      bind "]" { BreakPaneRight; SwitchToMode "locked"; }
                      bind "b" { BreakPane; SwitchToMode "locked"; }
                      bind "h" { GoToPreviousTab; }
                      bind "j" { GoToNextTab; }
                      bind "k" { GoToPreviousTab; }
                      bind "l" { GoToNextTab; }
                      bind "n" { NewTab; SwitchToMode "locked"; }
                      bind "r" { SwitchToMode "renametab"; TabNameInput 0; }
                      bind "s" { ToggleActiveSyncTab; SwitchToMode "locked"; }
                      bind "t" { SwitchToMode "normal"; }
                      bind "x" { CloseTab; SwitchToMode "locked"; }
                      bind "tab" { ToggleTab; }
                  }
                  resize {
                      bind "left" { Resize "Increase left"; }
                      bind "down" { Resize "Increase down"; }
                      bind "up" { Resize "Increase up"; }
                      bind "right" { Resize "Increase right"; }
                      bind "+" { Resize "Increase"; }
                      bind "-" { Resize "Decrease"; }
                      bind "=" { Resize "Increase"; }
                      bind "H" { Resize "Decrease left"; }
                      bind "J" { Resize "Decrease down"; }
                      bind "K" { Resize "Decrease up"; }
                      bind "L" { Resize "Decrease right"; }
                      bind "h" { Resize "Increase left"; }
                      bind "j" { Resize "Increase down"; }
                      bind "k" { Resize "Increase up"; }
                      bind "l" { Resize "Increase right"; }
                      bind "r" { SwitchToMode "normal"; }
                  }
                  move {
                      bind "left" { MovePane "left"; }
                      bind "down" { MovePane "down"; }
                      bind "up" { MovePane "up"; }
                      bind "right" { MovePane "right"; }
                      bind "h" { MovePane "left"; }
                      bind "j" { MovePane "down"; }
                      bind "k" { MovePane "up"; }
                      bind "l" { MovePane "right"; }
                      bind "m" { SwitchToMode "normal"; }
                      bind "n" { MovePane; }
                      bind "p" { MovePaneBackwards; }
                      bind "tab" { MovePane; }
                  }
                  scroll {
                      bind "Alt left" { MoveFocusOrTab "left"; SwitchToMode "locked"; }
                      bind "Alt down" { MoveFocus "down"; SwitchToMode "locked"; }
                      bind "Alt up" { MoveFocus "up"; SwitchToMode "locked"; }
                      bind "Alt right" { MoveFocusOrTab "right"; SwitchToMode "locked"; }
                      bind "e" { EditScrollback; SwitchToMode "locked"; }
                      bind "f" { SwitchToMode "entersearch"; SearchInput 0; }
                      bind "Alt h" { MoveFocusOrTab "left"; SwitchToMode "locked"; }
                      bind "Alt j" { MoveFocus "down"; SwitchToMode "locked"; }
                      bind "Alt k" { MoveFocus "up"; SwitchToMode "locked"; }
                      bind "Alt l" { MoveFocusOrTab "right"; SwitchToMode "locked"; }
                      bind "s" { SwitchToMode "normal"; }
                  }
                  search {
                      bind "c" { SearchToggleOption "CaseSensitivity"; }
                      bind "n" { Search "down"; }
                      bind "o" { SearchToggleOption "WholeWord"; }
                      bind "p" { Search "up"; }
                      bind "w" { SearchToggleOption "Wrap"; }
                  }
                  session {
                      bind "a" {
                          LaunchOrFocusPlugin "zellij:about" {
                              floating true
                              move_to_focused_tab true
                          }
                          SwitchToMode "locked"
                      }
                      bind "c" {
                          LaunchOrFocusPlugin "configuration" {
                              floating true
                              move_to_focused_tab true
                          }
                          SwitchToMode "locked"
                      }
                      bind "d" { Detach; }
                      bind "o" { SwitchToMode "normal"; }
                      bind "p" {
                          LaunchOrFocusPlugin "plugin-manager" {
                              floating true
                              move_to_focused_tab true
                          }
                          SwitchToMode "locked"
                      }
                      bind "s" {
                          LaunchOrFocusPlugin "zellij:share" {
                              floating true
                              move_to_focused_tab true
                          }
                          SwitchToMode "locked"
                      }
                      bind "w" {
                          LaunchOrFocusPlugin "session-manager" {
                              floating true
                              move_to_focused_tab true
                          }
                          SwitchToMode "locked"
                      }
                  }
                  shared_among "normal" "locked" {
                      bind "Alt left" { MoveFocus "left"; }
                      bind "Alt down" { MoveFocus "down"; }
                      bind "Alt up" { MoveFocus "up"; }
                      bind "Alt right" { MoveFocus "right"; }
                      bind "Ctrl f" { ToggleFloatingPanes; }
                      bind "Ctrl n" { NewPane; }
                      bind "Ctrl x" { CloseFocus; }
                      bind "Alt f" { ToggleFocusFullscreen; }
                      bind "Alt p" { TogglePaneInGroup; }
                      bind "Alt Shift p" { ToggleGroupMarking; }
                      bind "Ctrl e" { Run "nvim" { close_on_exit true; };}
                      bind "Ctrl g" { NewTab { layout "${lazygitLayout}"; }; }
                      bind "Ctrl m" { NewTab { layout "${sysmonLayout}"; }; }

                  }
                  shared_except "locked" "renametab" "renamepane" {
                      bind "Ctrl q" { Quit; }
                  }
                  shared_except "locked" "entersearch" {
                      bind "enter" { SwitchToMode "locked"; }
                  }
                  shared_except "locked" "entersearch" "renametab" "renamepane" {
                      bind "esc" { SwitchToMode "locked"; }
                  }
                  shared_except "locked" "entersearch" "renametab" "renamepane" "move" {
                      bind "m" { SwitchToMode "move"; }
                  }
                  shared_except "locked" "entersearch" "search" "renametab" "renamepane" "session" {
                      bind "o" { SwitchToMode "session"; }
                  }
                  shared_except "locked" "tab" "entersearch" "renametab" "renamepane" {
                      bind "t" { SwitchToMode "tab"; }
                  }
                  shared_among "normal" "resize" "tab" "scroll" "prompt" "tmux" {
                      bind "p" { SwitchToMode "pane"; }
                  }
                  shared_among "normal" "resize" "search" "move" "prompt" "tmux" {
                      bind "s" { SwitchToMode "scroll"; }
                  }
                  shared_except "locked" "resize" "pane" "tab" "entersearch" "renametab" "renamepane" {
                      bind "r" { SwitchToMode "resize"; }
                  }
                  shared_among "scroll" "search" {
                      bind "PageDown" { PageScrollDown; }
                      bind "PageUp" { PageScrollUp; }
                      bind "left" { PageScrollUp; }
                      bind "down" { ScrollDown; }
                      bind "up" { ScrollUp; }
                      bind "right" { PageScrollDown; }
                      bind "Ctrl b" { PageScrollUp; }
                      bind "Ctrl c" { ScrollToBottom; SwitchToMode "locked"; }
                      bind "d" { HalfPageScrollDown; }
                      bind "Ctrl f" { PageScrollDown; }
                      bind "h" { PageScrollUp; }
                      bind "j" { ScrollDown; }
                      bind "k" { ScrollUp; }
                      bind "l" { PageScrollDown; }
                      bind "u" { HalfPageScrollUp; }
                  }
                  entersearch {
                      bind "Ctrl c" { SwitchToMode "scroll"; }
                      bind "esc" { SwitchToMode "scroll"; }
                      bind "enter" { SwitchToMode "search"; }
                  }
                  renametab {
                      bind "esc" { UndoRenameTab; SwitchToMode "tab"; }
                  }
                  shared_among "renametab" "renamepane" {
                      bind "Ctrl c" { SwitchToMode "locked"; }
                  }
                  renamepane {
                      bind "esc" { UndoRenamePane; SwitchToMode "pane"; }
                  }
              }
            '';
        };
    };
}
