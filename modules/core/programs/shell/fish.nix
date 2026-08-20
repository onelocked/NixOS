{
  exo.core =
    {
      scheme,
      config,
      theme,
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
                          eza --tree --level=3 --color=always --icons=always -- {2} 2>/dev/null | tail -n +2
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
              set -g fish_color_operator           "${if theme == "dark" then base15 else base0C}"
              set -g fish_color_escape             "${base09}"
              set -g fish_color_quote              "${base0B}"
              set -g fish_color_param              "${if theme == "dark" then base16 else base0D}"
              set -g fish_color_error              "${base08}"


              set -g fish_color_redirection        "${base0C}"
              set -g fish_color_end                "${if theme == "dark" then base17 else base0E}"
              set -g fish_color_directory          "${base0A}"
              set -g fish_color_commandpath        "${base0D}"
              set -g fish_color_bracket            "${base0B}"
            '';
        };
      };
      environment.shellAliases = {
        gr = "cd (git rev-parse --show-toplevel)";
      };
    };

  exo.skeleton =
    {
      lib,
      config,
      wrapPackage,
      pkgs,
      self',
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
        hj.packages = with pkgs; [
          cfg.atuin
          zoxide
          eza
          lsof
          fd
          jq
          wget
          unzip
          ripgrep
          killall
          scooter # search and replace
          self'.packages.systemctl-tui
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
                  fishIndent "${name}.fish" # fish
                    ''
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
          default = wrapPackage {
            package = pkgs.atuin;
            files.configuration."config.toml" = wrapPackage.toml {
              enter_accept = true;
              filter_mode = "session-preload";
              search_mode = "fuzzy";
            };
            env.ATUIN_CONFIG_DIR = wrapPackage.out + "configuration";
          };
        };
      };
    };
  tack.inputs.fetch.systemctl-tui = "gh:rgwood/systemctl-tui";
  perSystem =
    { inputs, pkgs, ... }:
    {
      packages.systemctl-tui = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        pname = "systemctl-tui";
        version = "git";
        src = inputs.systemctl-tui;
        cargoLock.lockFile = finalAttrs.src + "/Cargo.lock";
        doCheck = false;
        cargoBuildFlags = [
          "--config"
          "profile.release.strip=true"
        ];
        postInstall = "ln -s $out/bin/systemctl-tui $out/bin/isd ";
        patches = [
          (pkgs.writeText "square-borders.patch" # rust
            ''
              diff --git a/crates/systemctl-tui/src/components/home.rs b/crates/systemctl-tui/src/components/home.rs
              index 4787c78..3cb1215 100644
              --- a/crates/systemctl-tui/src/components/home.rs
              +++ b/crates/systemctl-tui/src/components/home.rs
              @@ -2071,7 +2071,7 @@ impl Component for Home {
                     .block(
                       Block::default()
                         .borders(Borders::ALL)
              -          .border_type(BorderType::Rounded)
              +          .border_type(BorderType::Plain)
                         .border_style(if self.mode == Mode::ServiceList {
                           Style::default().fg(theme.accent)
                         } else {
              @@ -2285,7 +2285,7 @@ impl Component for Home {
                   let logs_panel = right_panel[1];

                   let details_block =
              -      Block::default().title(block_title("Details")).borders(Borders::ALL).border_type(BorderType::Rounded);
              +      Block::default().title(block_title("Details")).borders(Borders::ALL).border_type(BorderType::Plain);
                   let details_inner = details_block.inner(details_panel);
                   f.render_widget(details_block, details_panel);

              @@ -2441,7 +2441,7 @@ impl Component for Home {
                       Block::default()
                         .title(block_title(format!("Logs — {logs_unit} [{order_label}; ctrl+r to reverse]")))
                         .borders(Borders::ALL)
              -          .border_type(BorderType::Rounded),
              +          .border_type(BorderType::Plain),
                     )
                     .style(Style::default())
                     .wrap(Wrap { trim: true });
              @@ -2529,7 +2529,7 @@ impl Component for Home {
                       _ => Style::default(),
                     })
                     .scroll((0, scroll as u16))
              -      .block(Block::default().borders(Borders::ALL).border_type(BorderType::Rounded).title(block_title(Line::from(
              +      .block(Block::default().borders(Borders::ALL).border_type(BorderType::Plain).title(block_title(Line::from(
                       vec![
                         Span::raw("Search "),
                         Span::styled("(", Style::default().fg(theme.muted_alt)),
              @@ -2592,7 +2592,7 @@ impl Component for Home {
                     let title = format!("Help for {name} v{version}");

                     let paragraph = Paragraph::new(help_lines)
              -        .block(Block::default().title(block_title(title)).borders(Borders::ALL).border_type(BorderType::Rounded))
              +        .block(Block::default().title(block_title(title)).borders(Borders::ALL).border_type(BorderType::Plain))
                       .style(Style::default())
                       .wrap(Wrap { trim: true });

              @@ -2608,7 +2608,7 @@ impl Component for Home {
                         Block::default()
                           .title(block_title("Error"))
                           .borders(Borders::ALL)
              -            .border_type(BorderType::Rounded)
              +            .border_type(BorderType::Plain)
                           .border_style(Style::default().fg(Color::Red)),
                       )
                       .wrap(Wrap { trim: true });
              @@ -2645,7 +2645,7 @@ impl Component for Home {
                         Block::default()
                           .title(block_title(title))
                           .borders(Borders::ALL)
              -            .border_type(BorderType::Rounded)
              +            .border_type(BorderType::Plain)
                           .border_style(Style::default().fg(theme.accent))
                           .padding(ratatui::widgets::Padding::horizontal(1)),
                       )
              @@ -2764,7 +2764,7 @@ impl Component for Home {
                     let paragraph = Paragraph::new(lines).block(
                       Block::default()
                         .borders(Borders::ALL)
              -          .border_type(BorderType::Rounded)
              +          .border_type(BorderType::Plain)
                         .border_style(Style::default().fg(theme.accent))
                         .title(block_title("Unit filters")),
                     );
              @@ -2840,7 +2840,7 @@ impl Component for Home {

                     let outer = Block::default()
                       .borders(Borders::ALL)
              -        .border_type(BorderType::Rounded)
              +        .border_type(BorderType::Plain)
                       .border_style(Style::default().fg(theme.accent))
                       .title(block_title("All commands"));
                     f.render_widget(Clear, popup);
              @@ -2852,7 +2852,7 @@ impl Component for Home {
                     let search_width = search_rect.width.saturating_sub(2).max(1);
                     let scroll = self.command_input.visual_scroll(search_width as usize);
                     let search = Paragraph::new(self.command_input.value()).scroll((0, scroll as u16)).block(
              -        Block::default().borders(Borders::ALL).border_type(BorderType::Rounded).title(block_title("Search commands")),
              +        Block::default().borders(Borders::ALL).border_type(BorderType::Plain).title(block_title("Search commands")),
                     );
                     f.render_widget(search, search_rect);

              @@ -2904,7 +2904,7 @@ impl Component for Home {
                       .block(
                         Block::default()
                           .borders(Borders::ALL)
              -            .border_type(BorderType::Rounded)
              +            .border_type(BorderType::Plain)
                           .border_style(Style::default().fg(theme.accent))
                           .title(block_title(title)),
                       )
              @@ -2939,7 +2939,7 @@ impl Component for Home {
                       .block(
                         Block::default()
                           .title(block_title("Processing"))
              -            .border_type(BorderType::Rounded)
              +            .border_type(BorderType::Plain)
                           .borders(Borders::ALL)
                           .border_style(Style::default().fg(theme.accent)),
                       )
              diff --git a/crates/systemctl-tui/src/components/logger.rs b/crates/systemctl-tui/src/components/logger.rs
              index f58152c..fe6527d 100644
              --- a/crates/systemctl-tui/src/components/logger.rs
              +++ b/crates/systemctl-tui/src/components/logger.rs
              @@ -28,7 +28,7 @@ impl Component for Logger {
                       Block::default()
                         .title(block_title("systemctl-tui logs"))
                         .borders(Borders::ALL)
              -          .border_type(BorderType::Rounded),
              +          .border_type(BorderType::Plain),
                     )
                     .style_error(Style::default().fg(Color::Red))
                     .style_debug(Style::default().fg(Color::Green))
            ''
          )
        ];

      });
    };
}
