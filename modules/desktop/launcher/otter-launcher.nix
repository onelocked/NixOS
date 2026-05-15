{
  m.otter-launcher =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.forte.otter-launcher;
      aemeath = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/aemeath.png";
        hash = "sha256-QzUFj6f5KB8uLiZ8+YIcZl3zMGRpVLz3LFl8NoqjBjU=";
      };
    in
    {
      forte.otter-launcher = {
        settings = {
          general = {
            callback = "";
            cheatsheet_entry = "?";
            cheatsheet_viewer = "less -R; clear";
            clear_screen_after_execution = true;
            default_module = if cfg.withFsel then "app" else "np";
            empty_module = if cfg.withFsel then "search" else "mix";
            delay_startup = 0;
            esc_to_abort = true;
            exec_cmd = "sh -c";
            external_editor = "nvim";
            loop_mode = false;
            vi_mode = false;
          };

          overlay = {
            overlay_cmd = "chafa -s x11 ${aemeath}";
            overlay_trimmed_lines = 0;
            move_overlay_right = 26;
            move_overlay_down = 1;
          };

          interface =
            let
              esc = (fromTOML ''value = "\u001b"'').value;
            in
            {
              move_interface_down = 1;
              move_interface_right = 1;
              header = ''
                ┌── ${esc}[1;34m $USER@$(echo $HOSTNAME) ${esc}[0m ──┐
                │ ${esc}[58m  ${esc}[31m  ${esc}[32m  ${esc}[33m  ${esc}[34m  ${esc}[35m  ${esc}[36m${esc}[0m │
                │ ${esc}[33m ${esc}[1;35m system${esc}[0m     NixOS │
                │ ${esc}[36m ${esc}[1;35m wm ${esc}[0m         $XDG_CURRENT_DESKTOP │
                │ ${esc}[31m ${esc}[1;35m loads${esc}[0m       $(cat /proc/loadavg | cut -d ' ' -f 1) │
                └ ${esc}[32m ${esc}[1;35m memory${esc}[0m     $(free -h | awk 'FNR == 2 {print $3}') ┘
                  ${esc}[90m${esc}[0m  '';
              list_prefix = "   ${esc}[90m╰··${esc}[0m ${esc}[34m󰅂 ";
              selection_prefix = "   ${esc}[1;35m╰━━${esc}[0m ${esc}[1;31m❯ ";
              default_module_message = "   ${esc}[90m╰··${esc}[0m ${esc}[34m  ${esc}[33mapp${esc}[0m search";
              place_holder = "type & search";
              place_holder_color = "${esc}[90m";
              suggestion_mode = "list";
              suggestion_lines = 4;
              prefix_color = "${esc}[33m";
              description_color = "${esc}[39m";
              hint_color = "${esc}[90m";
            };

          modules =
            let
              inherit (config.forte.lib) resize;
            in
            [
              {
                description = "run commands";
                "prefix" = "sh";
                cmd = ''$(printf $TERM | sed 's/xterm-//g') -e sh -c "{}"'';
                with_argument = true;
                unbind_proc = true;
              }
              {
                description = "nix packages";
                "prefix" = "np";
                cmd = "xdg-open 'https://search.nixos.org/packages?channel=unstable&query={}'";
                with_argument = true;
                url_encode = true;
                unbind_proc = true;
              }
              {
                description = "nix options";
                "prefix" = "no";
                cmd = "xdg-open 'https://search.nixos.org/options?channel=unstable&include_home_manager_options=0&include_modular_service_options=0&include_nixos_options=1&query={}'";
                with_argument = true;
                url_encode = true;
                unbind_proc = true;
              }
              {
                description = "sys mon";
                "prefix" = "btop";
                cmd = resize 2100 1200 "btop";
              }
              {
                description = "systemd";
                "prefix" = "isd";
                cmd = resize 2100 1200 "isd";
              }
              {
                description = "audio";
                "prefix" = "mix";
                cmd = resize 800 500 "pulsemixer";
              }
              {
                description = "notepad";
                "prefix" = "nap";
                cmd = resize 2500 1200 "nap";
              }
              {
                description = "video";
                "prefix" = "mpv";
                cmd = "mpv-wlpaste";
              }
              {
                description = "yazi";
                "prefix" = "y";
                cmd = resize 2100 1100 "yazi";
              }
            ]
            ++ lib.optionals cfg.withFsel [
              {
                description = "apps";
                "prefix" = "search";
                cmd = resize 450 650 ''`fsel --launch-prefix='app2unit --' -vv -d -r -ss "{}"`'';
                with_argument = true;
              }
              {
                description = "launch";
                "prefix" = "app";
                cmd = resize 450 650 ''`fsel --launch-prefix='app2unit --' -vv -d -r -p "{}"`'';
                with_argument = true;
              }
            ];
        };
      };
      forte.niri.settings = {
        binds = {
          "Mod+SPACE" = _: {
            props = {
              repeat = false;
              hotkey-overlay-title = "Launcher";
            };
            content = {
              spawn-sh = [
                "pkill otter-launcher || kitty --app-id=otter-launcher -o font_size=15 -e otter-launcher"
              ];
            };
          };
        };
        window-rules = [
          {
            matches = [ { app-id = "^otter-launcher$"; } ];
            open-floating = true;
            opacity = 0.95;
            default-column-width.fixed = 620;
            default-window-height.fixed = 355;
          }
        ];
      };
    };

  envoy = {
    otter-launcher.github = "kuokuo123/otter-launcher";
    fsel.github = "Mjoyufull/fsel";
  };
  m.default =
    {
      self',
      wrappers,
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.forte.otter-launcher;
      toml = pkgs.formats.toml { };
    in
    {
      options.forte.lib = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        default = { };
      };
      options.forte.otter-launcher = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable otter-launcher.";
        };

        withFsel = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable fsel support.";
        };

        settings = lib.mkOption {
          inherit (toml) type;
          default = { };
          description = "Options to go into otter-launcher's toml config";
        };

        moreCfg = lib.mkOption {
          type = with lib.types; nullOr (either path lines);
          default = "";
          description = "Additional config lines.";
          example = lib.literalExpression "./config.toml";
        };

        package = lib.mkOption {
          default = wrappers.lib.wrapPackage (
            { config, ... }:
            {
              inherit pkgs;
              package = self'.packages.otter-launcher;
              flags = {
                "--config" = config.constructFiles.generatedConfig.path;
              };
              constructFiles.generatedConfig = {
                relPath = "config.toml";
                builder = ''
                  mkdir -p "$(dirname "$2")"
                  cat ${toml.generate "config.toml" cfg.settings} > "$2"
                  printf '%s\n' "${cfg.moreCfg}" >> "$2"
                '';
              };
              extraPackages = [
                pkgs.pulsemixer
                pkgs.chafa
              ]
              ++ lib.optional cfg.withFsel self'.packages.fsel;
            }
          );
        };
      };
      config = lib.mkIf (cfg.enable) {
        hj.packages = [ cfg.package ];
        forte.lib.resize =
          width: height: app:
          "niri msg action set-window-width ${toString width};niri msg action set-window-height ${toString height};niri msg action center-window;${app}";
      };
    };

  perSystem =
    {
      pkgs,
      envoy,
      wrappers,
      ...
    }:
    {
      packages = {
        otter-launcher = pkgs.rustPlatform.buildRustPackage {
          inherit (envoy.otter-launcher) pname version src;
          cargoHash = "sha256-AlzCrK6DivOfCMGXQsiMJ+7Ahtd/9qoJ0MKZrez6xyM=";
        };
        fsel = wrappers.lib.wrapPackage (
          { config, ... }:
          {
            inherit pkgs;
            extraPackages = [ pkgs.app2unit ];
            package = (
              pkgs.rustPlatform.buildRustPackage {
                inherit (envoy.fsel) pname version src;
                cargoHash = "sha256-G1wfue1Q+3NMH/5NqPVKeO0NpU0WJlwWkh51r3TM5IM=";
              }
            );
            flags = {
              "--config" = config.constructFiles.generatedConfig.path;
            };
            constructFiles.generatedConfig = {
              relPath = "config.toml";
              builder = ''mkdir -p "$(dirname "$2")" && cp ${
                (pkgs.formats.toml { }).generate "config.toml" {
                  main_border_color = "#7d75c0";
                  apps_border_color = "#7d75c0";
                  input_border_color = "#c8b0e8";

                  main_text_color = "#cfd3e7";
                  apps_text_color = "#8c92aa";
                  input_text_color = "#c8b0e8";

                  highlight_color = "#c5c0ff";
                  header_title_color = "#7d75c0";

                  pin_color = "#c8b0e8";
                  pin_icon = "󰐃";
                  cursor = "▎";
                  disable_mouse = true;

                  rounded_borders = true;
                  title_panel_height_percent = 20;
                  title_panel_position = "bottom";
                  fancy_mode = true;

                  app_launcher = {
                    filter_desktop = true;
                    filter_actions = true;
                    list_executables_in_path = false;
                    launch_prefix = [
                      "app2unit"
                      "--"
                    ];
                  };
                  dmenu = {
                    delimiter = " ";
                    show_line_numbers = true;
                  };
                }
              } "$2"'';
            };
          }
        );
      };
    };
}
