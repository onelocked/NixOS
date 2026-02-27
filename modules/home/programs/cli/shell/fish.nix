{
  flake.homeModules.fish = {
    programs.fish = {
      enable = true;
      functions = {
        # Transient Prompt
        starship_transient_prompt_func = ''
          printf " \e[38;2;142;192;124m\e[0m "
        '';

        # Shift + Z Zoxide picker
        __zoxide_interactive = # fish
          ''
            set dir (zoxide query --interactive | string trim)

            if test -n "$dir"
              cd "$dir"
              y
              commandline -f repaint
            end
          '';
        nrun = # fish
          ''
            set -l package $argv[1]
            nix run "nixpkgs#$package"
          '';

        # Open a nix shell with a package
        nget = # fish
          ''
            set -l package $argv[1]
            nix shell "nixpkgs#$package"
          '';
      };
      interactiveShellInit = # fish
        ''
          set -g fish_greeting # Disable greeting

          bind Z __zoxide_interactive

          # Gruvbox Dark Palette for Fish
          # --- Base Colors ---
          set -g fish_color_normal        "#ebdbb2"  # rosewater / text
          set -g fish_color_command       "#83a598"  # blue / recognized_command
          set -g fish_color_keyword       "#b16286"  # mauve / shape_keyword
          set -g fish_color_string        "#8ec07c"  # teal / string
          set -g fish_color_operator      "#83a598"  # sky / operator
          set -g fish_color_comment       "#928374"  # overlay2 / comments
          set -g fish_color_error         "#fb4934"  # red / errors
          set -g fish_color_param         "#fe8019"  # flamingo / variables
          set -g fish_color_quote         "#8ec07c"  # string quotes
          set -g fish_color_redirection   "#83a598"  # operator symbols > |
          set -g fish_color_end           "#d3869b"  # pink / special chars
          set -g fish_color_autosuggestion "#7c6f64" # overlay1
          set -g fish_color_search_match  --bold --underline "#b8bb26" # green / search match
          set -g fish_color_selection      "#458588"  # sapphire / selection

          # --- Cursor ---
          set -g fish_color_cursor          "#282828"  # base background
          set -g fish_color_cursor_foreground "#ebdbb2" # rosewater text

          # --- Path / File Highlights ---
          set -g fish_color_directory     "#fabd2f"  # yellow / file paths
          set -g fish_color_commandpath   "#83a598"  # blue / recognized commands

          # --- Virtual Text / UI elements ---
          # Not all Nushell shapes exist in Fish; closest mapping:
          set -g fish_color_bracket       "#b8bb26"  # green / matching brackets
          set -g fish_color_escape        "#fe8019"  # flamingo / escapes
          set -g fish_color_operator      "#83a598"  # sky / operator symbols

          # --- Background / Terminal Colors ---
          # Fish doesn't control terminal background fully; just set defaults
          set -g fish_color_normal_bg     "#282828"  # base / background
          set -g fish_color_comment_bg    "#32302f"  # surface0
        '';
    };
  };
}
