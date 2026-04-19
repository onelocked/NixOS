{
  m.fish =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      programs = {
        bash.interactiveShellInit =
          lib.mkIf config.programs.fish.enable or false # bash
            ''
              if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
              then
                shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
                exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
              fi
            '';
        fish = {
          enable = true;
          functions = {
            store = ''y (string match -r "/nix/store/[^/]*" (builtin realpath (type -fP $argv[1])))'';
            ncp = ''echo "pkgs.$(nurl $argv[1]);" | string collect  | wl-copy'';

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

            "__yazi-fuzzy-zoxide" = # fish
              ''
                set -l dir (
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
                      --ansi --no-sort --height=100% --layout=reverse --info=inline-right \
                      --scheme=path --delimiter='\t' --with-nth=1 \
                      --prompt "󰰷 Zoxide: ➜ " --pointer="▶" --separator "─" \
                      --scrollbar "│" --border="rounded" --padding="1,2" \
                      --header " Rank │  Directory" \
                      --preview '
                          printf "   Tree Structure\n";
                          printf "  \033[2m────────────────\033[0m\n";
                          eza -TL=3 --color=always --icons {2} 2>/dev/null | tail -n +2
                      ' \
                      --preview-window="right:50%:wrap:border-left" \
                      --bind "ctrl-j:down,ctrl-k:up" \
                      --bind "ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up" \
                  | cut -f2 | string trim
                )

                if test -n "$dir"
                    cd "$dir"
                    y
                end
                commandline -f repaint
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
              bind Z __yazi-fuzzy-zoxide
              bind -M insert Z __yazi-fuzzy-zoxide
            '';
          shellInit = # fish
            ''
              set -g fish_greeting # Disable greeting

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
      hj.xdg.config.files =
        let

          # Adapted from home-manager (https://github.com/nix-community/home-manager/blob/master/modules/programs/fish.nix)
          fishIndent =
            name: text:
            pkgs.runCommand name {
              nativeBuildInputs = [ pkgs.fish ];
              inherit text;
              passAsFile = [ "text" ];
            } "env HOME=$(mktemp -d) fish_indent < $textPath > $out";

          inherit (lib) optional isAttrs;
        in
        config.programs.fish.functions
        |> lib.mapAttrs' (
          name: def: {
            name = "fish/functions/${name}.fish";
            value = {
              source =
                let
                  modifierStr = n: v: optional (v != null) ''--${n}="${toString v}"'';
                  modifierStrs = n: v: optional (v != null) "--${n}=${toString v}";
                  modifierBool = n: v: optional (v != null && v) "--${n}";

                  mods =
                    with def;
                    modifierStr "description" description
                    ++ modifierStr "wraps" wraps
                    ++ (onEvent |> lib.toList |> lib.concatMap (modifierStr "on-event"))
                    ++ modifierStr "on-variable" onVariable
                    ++ modifierStr "on-job-exit" onJobExit
                    ++ modifierStr "on-process-exit" onProcessExit
                    ++ modifierStr "on-signal" onSignal
                    ++ modifierBool "no-scope-shadowing" noScopeShadowing
                    ++ modifierStr "inherit-variable" inheritVariable
                    ++ modifierStrs "argument-names" argumentNames;

                  modifiers = if isAttrs def then " ${toString mods}" else "";
                  body = if isAttrs def then def.body else def;
                in
                fishIndent "${name}.fish" ''
                  function ${name}${modifiers}
                    ${body |> lib.strings.removeSuffix "\n"}
                  end
                '';
            };
          }
        );
    };

  m.default =
    { lib, ... }:
    {
      options.programs.fish = {
        functions = lib.mkOption {
          default = { };
          type = with lib.types; attrsOf (either lines functionModule);
          description = "Set custom fish functions.";
        };
      };
    };
}
