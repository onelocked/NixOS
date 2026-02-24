{
  flake.homeModules.cli = {
    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        add_newline = false;
        format = "[ 󰪥 $directory ](color_green)$character";
        palette = "gruvbox";
        right_format = "$all";
        command_timeout = 1000;

        character = {
          vimcmd_symbol = "[](color_teal)";
          success_symbol = "[➜](color_dark_green)";
          error_symbol = "[](color_pink)";
        };
        git_branch = {
          format = "[$symbol$branch(:$remote_branch)](color_teal1)";
          symbol = "󰘬 ";
        };
        git_commit = {
          commit_hash_length = 6;
          tag_symbol = " ";
        };
        git_status = {
          ahead = "  ";
          behind = "  ";
          untracked = " 󰯇 ";
          modified = "  ";
          deleted = "  ";
        };
        directory = {
          read_only = " ";
          truncation_length = 6;
          format = "[󰉋 ](sapphire)[$path](color_orange)";
        };

        golang = {
          format = "[ ](bold cyan)";
        };
        nix_shell = {
          format = "[$symbol$state( ($name))](color_fg0) ";
          impure_msg = "[impure](color_red1)";
          pure_msg = "[pure](color_green)";
          symbol = " ";
        };

        docker_context = {
          symbol = "[󰡨 ](bold sky)";
        };

        palettes.gruvbox = {
          color_fg0 = "#fbf1c7";
          color_bg1 = "#3c3836";
          color_bg3 = "#665c54";
          color_blue = "#458588";
          color_aqua = "#689d6a";
          color_green = "#98971a";
          color_dark_green = "#b8bb26";
          color_teal = "#458588";
          color_teal1 = "#83a598";
          color_orange = "#d79921";
          color_purple = "#b16286";
          color_red = "#cc241d";
          color_red1 = "#fb4934";
          color_yellow = "#d79921";
          color_pink = "#d3869b";
        };
      };
    };
  };
}
