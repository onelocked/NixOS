{
  flake.modules.homeManager.zellij =
    { pkgs, ... }:
    {
      programs.zellij.settings =
        let
          theme =
            pkgs.writeTextDir "mocha.kdl" # kdl
              ''
                themes {
                    mocha {
                        text_unselected {
                            base 207 211 231
                            background 19 19 22
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
                            base 53 53 67
                            background 0
                            emphasis_0 242 184 160
                            emphasis_1 197 192 255
                            emphasis_2 200 176 232
                            emphasis_3 0
                        }
                        frame_unselected {
                            base 19 19 22
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
          theme = "mocha";
          theme_dir = "${theme}";
        };
    };
}
