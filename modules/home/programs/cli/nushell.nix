{ inputs, ... }:
{
  flake.homeModules.cli =
    { pkgs, lib, ... }:
    {
      home.shell.enableNushellIntegration = true;
      programs = {
        nix-your-shell = {
          enable = true;
          enableNushellIntegration = true;
        };
        atuin = {
          enable = true;
          enableNushellIntegration = true;
          settings = {
            search_mode = "fuzzy";
            filter_mode = "session-preload";
          };
        };
        pay-respects = {
          enable = true;
          enableNushellIntegration = true;
        };
        zoxide = {
          enable = true;
          enableNushellIntegration = true;
        };
        carapace = {
          enable = true;
          enableNushellIntegration = true;
        };
        nushell = {
          enable = true;
          shellAliases =
            let
              _ = lib.getExe;
            in
            {
              dots = "cd ~/NixOS";
              ping = "${_ pkgs.gping}";
              cat = "bat";
              zip = "${_ pkgs.zip}";
              ll = "${_ pkgs.eza} -l --icons --git -a";
              gtop = "${_ inputs.derivations.packages.${pkgs.stdenv.hostPlatform.system}.amdgpu_top} --dark";
            };

          configFile.text = # nu
            ''
              # Common ls aliases and sort them by type and then name
              def lla [...args] { ls -la ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
              def la  [...args] { ls -a  ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }

              alias ff = fastfetch
              alias fastfetish = fastfetch

              def nrun [package: string] {
                  ^nix run $"nixpkgs#($package)"
              }

              def nget [package: string] {
                  ^nix shell $"nixpkgs#($package)"
              }

              # Completions
              let carapace_completer = {|spans: list<string>|
                carapace $spans.0 nushell ...$spans
                | from json
                | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
              }

              # --- Zoxide interactive on Shift+Z ---
              $env.config.keybindings ++= [
                {
                  name: zoxide_interactive
                  modifier: shift
                  keycode: char_z
                  mode: [emacs, vi_normal, vi_insert]
                  event: {
                    send: executehostcommand
                    cmd: "Z"
                  }
                }
              ]

              def --env Z [] {
                let dir = (zoxide query --interactive | str trim)

                if ($dir | is-not-empty) {
                  cd $dir
                  y
                }
              }

            '';
          envFile.text = # nu
            ''
              # Nushell configuration settings
              $env.config = {
                highlight_resolved_externals: true,
                show_banner: false,
              }
              $env.PATH ++= [ "~/.nix-profile/bin" ]
              $env.EDITOR = "nvim"
              $env.CARAPACE_BRIDGES = 'zsh,bash'
              # Transient prompt
              $env.PROMPT_COMMAND_RIGHT = {|| "" } # Hide right prompt after enter

              $env.TRANSIENT_PROMPT_COMMAND = {|| $"(ansi { fg: '#8ec07c' })  (ansi reset)" }
              $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
              $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
              $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
              $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
            '';

          extraConfig = # nu
            ''
              # Theme
              let theme = {
                  rosewater: "#ebdbb2"
                  flamingo: "#fe8019"
                  pink: "#d3869b"
                  mauve: "#b16286"
                  red: "#fb4934"
                  maroon: "#cc241d"
                  peach: "#fe8019"
                  yellow: "#fabd2f"
                  green: "#b8bb26"
                  teal: "#8ec07c"
                  sky: "#83a598"
                  sapphire: "#458588"
                  blue: "#83a598"
                  lavender: "#a89984"
                  text: "#ebdbb2"
                  subtext1: "#bdae93"
                  subtext0: "#a89984"
                  overlay2: "#928374"
                  overlay1: "#7c6f64"
                  overlay0: "#665c54"
                  surface2: "#504945"
                  surface1: "#3c3836"
                  surface0: "#32302f"
                  base: "#282828"
                  mantle: "#1d2021"
                  crust: "#1b1b1b"
                }

                let scheme = {
                  recognized_command: $theme.blue
                  unrecognized_command: $theme.text
                  constant: $theme.peach
                  punctuation: $theme.overlay2
                  operator: $theme.sky
                  string: $theme.green
                  virtual_text: $theme.surface2
                  variable: { fg: $theme.flamingo attr: i }
                  filepath: $theme.yellow
                }

                $env.config.color_config = {
                  separator: { fg: $theme.surface2 attr: b }
                  leading_trailing_space_bg: { fg: $theme.lavender attr: u }
                  header: { fg: $theme.text attr: b }
                  row_index: $scheme.virtual_text
                  record: $theme.text
                  list: $theme.text
                  hints: $scheme.virtual_text
                  search_result: { fg: $theme.base bg: $theme.yellow }
                  shape_closure: $theme.teal
                  closure: $theme.teal
                  shape_flag: { fg: $theme.maroon attr: i }
                  shape_matching_brackets: { attr: u }
                  shape_garbage: $theme.red
                  shape_keyword: $theme.mauve
                  shape_match_pattern: $theme.green
                  shape_signature: $theme.teal
                  shape_table: $scheme.punctuation
                  cell-path: $scheme.punctuation
                  shape_list: $scheme.punctuation
                  shape_record: $scheme.punctuation
                  shape_vardecl: $scheme.variable
                  shape_variable: $scheme.variable
                  empty: { attr: n }
                  filesize: {||
                    if $in < 1kb {
                      $theme.teal
                    } else if $in < 10kb {
                      $theme.green
                    } else if $in < 100kb {
                      $theme.yellow
                    } else if $in < 10mb {
                      $theme.peach
                    } else if $in < 100mb {
                      $theme.maroon
                    } else if $in < 1gb {
                      $theme.red
                    } else {
                      $theme.mauve
                    }
                  }
                  duration: {||
                    if $in < 1day {
                      $theme.teal
                    } else if $in < 1wk {
                      $theme.green
                    } else if $in < 4wk {
                      $theme.yellow
                    } else if $in < 12wk {
                      $theme.peach
                    } else if $in < 24wk {
                      $theme.maroon
                    } else if $in < 52wk {
                      $theme.red
                    } else {
                      $theme.mauve
                    }
                  }
                  date: {|| (date now) - $in |
                    if $in < 1day {
                      $theme.teal
                    } else if $in < 1wk {
                      $theme.green
                    } else if $in < 4wk {
                      $theme.yellow
                    } else if $in < 12wk {
                      $theme.peach
                    } else if $in < 24wk {
                      $theme.maroon
                    } else if $in < 52wk {
                      $theme.red
                    } else {
                      $theme.mauve
                    }
                  }
                  shape_external: $scheme.unrecognized_command
                  shape_internalcall: $scheme.recognized_command
                  shape_external_resolved: $scheme.recognized_command
                  shape_block: $scheme.recognized_command
                  block: $scheme.recognized_command
                  shape_custom: $theme.pink
                  custom: $theme.pink
                  background: $theme.base
                  foreground: $theme.text
                  cursor: { bg: $theme.rosewater fg: $theme.base }
                  shape_range: $scheme.operator
                  range: $scheme.operator
                  shape_pipe: $scheme.operator
                  shape_operator: $scheme.operator
                  shape_redirection: $scheme.operator
                  glob: $scheme.filepath
                  shape_directory: $scheme.filepath
                  shape_filepath: $scheme.filepath
                  shape_glob_interpolation: $scheme.filepath
                  shape_globpattern: $scheme.filepath
                  shape_int: $scheme.constant
                  int: $scheme.constant
                  bool: $scheme.constant
                  float: $scheme.constant
                  nothing: $scheme.constant
                  binary: $scheme.constant
                  shape_nothing: $scheme.constant
                  shape_bool: $scheme.constant
                  shape_float: $scheme.constant
                  shape_binary: $scheme.constant
                  shape_datetime: $scheme.constant
                  shape_literal: $scheme.constant
                  string: $scheme.string
                  shape_string: $scheme.string
                  shape_string_interpolation: $theme.flamingo
                  shape_raw_string: $scheme.string
                  shape_externalarg: $scheme.string
                }
                $env.config.highlight_resolved_externals = true
                $env.config.explore = {
                    status_bar_background: { fg: $theme.text, bg: $theme.mantle },
                    command_bar_text: { fg: $theme.text },
                    highlight: { fg: $theme.base, bg: $theme.yellow },
                    status: {
                        error: $theme.red,
                        warn: $theme.yellow,
                        info: $theme.blue,
                    },
                    selected_cell: { bg: $theme.blue fg: $theme.base },
                }
            '';
        };
      };
    };
}
