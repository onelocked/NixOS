{
  exo.core =
    {
      pkgs,
      lib,
      scheme,
      config,
      ...
    }:
    {
      programs = {
        fish = {
          enable = true;
          extraCompletionPackages = config.hj.packages;
          functions = {
            store = ''y (string match -r "/nix/store/[^/]*" (builtin realpath (type -fP $argv[1])))'';
            mem = ''
              echo "   PID Command                        PSS"
              , smem -c "pid command pss" -nkP $argv[1] | tail -n+3
            '';
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
                      --scrollbar "│" --padding="1,2" \
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
          shellInit =
            with scheme.withHashtag; # fish
            ''
              bind Z __yazi-fuzzy-zoxide
              bind -M insert Z __yazi-fuzzy-zoxide

              set -g fish_greeting # Disable greeting

              set -g fish_color_normal             "${base05}"
              set -g fish_color_comment            "${base03}"
              set -g fish_color_autosuggestion     "${base04}"
              set -g fish_color_selection          "${base02}"
              set -g fish_color_cursor             "${base00}"
              set -g fish_color_cursor_foreground  "${base05}"
              set -g fish_color_search_match       --bold --underline "${base0A}"


              set -g fish_color_command            "${base0B}"
              set -g fish_color_keyword            "${base0E}"
              set -g fish_color_string             "${base0F}"
              set -g fish_color_operator           "${base15}"
              set -g fish_color_escape             "${base09}"
              set -g fish_color_quote              "${base0B}"
              set -g fish_color_param              "${base16}"
              set -g fish_color_error              "${base08}"


              set -g fish_color_redirection        "${base0C}"
              set -g fish_color_end                "${base17}"
              set -g fish_color_directory          "${base0A}"
              set -g fish_color_commandpath        "${base0D}"
              set -g fish_color_bracket            "${base0B}"
            '';
        };
      };
      environment.shellAliases =
        with pkgs;
        with lib;
        {
          ping = getExe gping;
          cat = getExe bat;
          zip = getExe zip;
          gr = "cd (git rev-parse --show-toplevel)";
          ils = "${getExe mcat} ls --hyprlink --kitty --ls-opts 'height=10%,items_per_row=6'";
          shutdown = ''hyprshutdown -t "Shutting down..." --post-cmd "shutdown -P 0"'';
          reboot = ''hyprshutdown -t "Restarting..." --post-cmd "reboot"'';
        };
    };

  exo.skeleton =
    {
      lib,
      config,
      birdee,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.fish;
    in
    {
      config = lib.mkIf cfg.enable {
        forte.persist = {
          home.directories = [
            ".local/share/atuin"
            ".local/share/fish"
            ".local/share/zoxide"
          ];
        };
        hj.packages = [
          cfg.atuin
          pkgs.zoxide
        ];
        programs.fish.interactiveShellInit = ''
          ${lib.getExe pkgs.zoxide} init fish | source
          ${lib.getExe pkgs.nix-your-shell} --nom fish | source
          ${lib.getExe cfg.atuin} init fish | source
        '';
        programs.bash.interactiveShellInit = # bash
          ''
            if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
            then
              shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
              exec ${cfg.package}/bin/fish $LOGIN_OPTION
            fi
          '';
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
          cfg.functions
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
      options.programs.fish = {
        functions = lib.mkOption {
          default = { };
          type = with lib.types; attrsOf (either lines functionModule);
          description = "Set custom fish functions.";
        };
        atuin = lib.mkOption {
          type = lib.types.package;
          description = "Atuin shell history package.";
          default = birdee.lib.wrapPackage (
            { config, ... }:
            {
              inherit pkgs;
              package = pkgs.atuin;
              env.ATUIN_CONFIG_DIR = dirOf config.constructFiles.atuin-config.path;
              constructFiles.atuin-config = {
                relPath = "atuin-config/config.toml";
                content = # toml
                  ''
                    enter_accept = true
                    filter_mode = "session-preload"
                    search_mode = "fuzzy"
                  '';
              };
            }
          );
        };
      };
    };
}
