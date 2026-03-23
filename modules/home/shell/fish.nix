{
  flake.modules.homeManager.fish =
    { pkgs, ... }:
    {
      programs.fish = {
        enable = true;
        plugins = with pkgs.fishPlugins; [
          {
            name = "autopair";
            src = autopair.src;
          }
        ];
        functions = {
          # Transient Prompt
          starship_transient_prompt_func = ''
            printf " \e[38;2;232;196;216m\e[0m "
          '';

          __zoxide_interactive = # fish
            ''
              set dir (
                  zoxide query -ls 2>/dev/null \
                  | awk -v home="$HOME" '{
                      score = $1
                      sub(/^[ \t]*[0-9.]+[ \t]+/, "", $0)
                      orig = $0
                      sub("^" home, "~", $0)

                      green = "\033[32m"
                      dim   = "\033[2m"
                      reset = "\033[0m"

                      printf "%s%6s %s│%s  %s\t%s\n", green, score, reset dim, reset, $0, orig
                  }' \
                  | fzf \
                      --ansi \
                      --no-sort \
                      --height=100% \
                      --layout=reverse \
                      --info=inline-right \
                      --scheme=path \
                      --delimiter='\t' \
                      --with-nth=1 \
                      --prompt "󰰷 Zoxide: ➜ " \
                      --pointer="▶" \
                      --separator "─" \
                      --scrollbar "│" \
                      --border="rounded" \
                      --padding="1,2" \
                      --header " Rank │  Directory" \
                      --preview 'eza -TL=3 --color=always --icons {2} 2>/dev/null || ls {2}' \
                      --preview-window="right:50%:wrap" \
                      --bind "ctrl-j:down,ctrl-k:up" \
                      --bind "ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up" \
                  | cut -f2 \
                  | string trim
              )

              if test -n "$dir"
                  cd "$dir"
                  y
                  zoxide add "$dir"
              end
              commandline -f repaint
            '';
          # Run a nix run with a package
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
        shellAbbrs = {
          nb = "nix build";
          nd = "nix develop";
          nr = "nix run";
          nf = "nix flake update";
          wf = "nix run ~/NixOS#write-flake";
        };
        interactiveShellInit = # fish
          ''
            set -g fish_greeting # Disable greeting
            fish_vi_key_bindings
            bind -M insert Z __zoxide_interactive
            bind Z __zoxide_interactive

            set -g fish_color_normal        "#cfd3e7"
            set -g fish_color_command       "#b8db8c"
            set -g fish_color_keyword       "#c8b0e8"
            set -g fish_color_string        "#c5c0ff"
            set -g fish_color_operator      "#8fd4b5"
            set -g fish_color_comment       "#454545"
            set -g fish_color_error         "#f4a8b8"
            set -g fish_color_param         "#a8c8f0"
            set -g fish_color_quote         "#b8db8c"
            set -g fish_color_redirection   "#7cb8d4"
            set -g fish_color_end           "#e8c4d8"
            set -g fish_color_autosuggestion "#787878"
            set -g fish_color_search_match  --bold --underline "#f6d88a"
            set -g fish_color_selection      "#a8c8f0"

            set -g fish_color_cursor          "#1e1e2e"
            set -g fish_color_cursor_foreground "#cfd3e7"

            set -g fish_color_directory     "#f6d88a"
            set -g fish_color_commandpath   "#7d75c0"

            set -g fish_color_bracket       "#b8db8c"
            set -g fish_color_escape        "#f2b8a0"
          '';
      };
    };
}
