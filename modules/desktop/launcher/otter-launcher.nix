{
  m.otter-launcher =
    {
      config,
      lib,
      pkgs,
      scheme,
      ...
    }:
    let
      theme = config.forte.theme.variant;
      fsel = config.forte.fsel;
      aemeath = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/aemeath.png";
        hash = "sha256-QzUFj6f5KB8uLiZ8+YIcZl3zMGRpVLz3LFl8NoqjBjU=";
      };
      nix-logo = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/nix-snowflake-dark.png";
        hash = "sha256-YLjkjECbUJJzyUs9igIG6aIWJX2c9BR/wmsjRE0YXug=";
      };
    in
    {
      forte.otter-launcher = {
        enable = true;
        settings = {
          general = {
            callback = "";
            cheatsheet_entry = "?";
            cheatsheet_viewer = "less -R; clear";
            clear_screen_after_execution = true;
            default_module = if fsel.enable then "app" else "np";
            empty_module = if fsel.enable then "search" else "mix";
            delay_startup = 0;
            esc_to_abort = true;
            exec_cmd = "sh -c";
            external_editor = "nvim";
            loop_mode = false;
            vi_mode = false;
          };

          overlay = {
            overlay_cmd = "chafa -s x11 ${if theme == "dark" then aemeath else nix-logo}";
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
                │ ${esc}[36m ${esc}[1;35m wm ${esc}[0m     $XDG_CURRENT_DESKTOP │
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
        };
        modules =
          let
            inherit (config.forte.lib) resize;
          in
          [
            {
              description = "nix packages";
              prefix = "np";
              cmd = "xdg-open 'https://search.nixos.org/packages?channel=unstable&query={}'";
              with_argument = true;
              url_encode = true;
              unbind_proc = true;
            }
            {
              description = "nix options";
              prefix = "no";
              cmd = "xdg-open 'https://search.nixos.org/options?channel=unstable&include_home_manager_options=0&include_modular_service_options=0&include_nixos_options=1&query={}'";
              with_argument = true;
              url_encode = true;
              unbind_proc = true;
            }
            {
              description = "sys mon";
              prefix = "btop";
              cmd = resize 2100 1200 "btop";
            }
            {
              description = "systemd";
              prefix = "isd";
              cmd = resize 2100 1200 "isd";
            }
            {
              description = "audio";
              prefix = "mix";
              cmd = resize 800 500 "wiremix";
            }
            {
              description = "notepad";
              prefix = "nap";
              cmd = resize 2500 1200 "nap";
            }
            {
              description = "yazi";
              prefix = "y";
              cmd = resize 2100 1100 "yazi";
            }
            {
              description = "color picker";
              prefix = "cp";
              cmd = "app2unit -- ${pkgs.writeShellScript "color-picker" ''
                sleep 0.25
                PICKED=$(${pkgs.hyprpicker}/bin/hyprpicker --radius=70 --scale=3 --autocopy --no-fancy --format=hex)
                if [ -n "$PICKED" ]; then
                  kitty --app-id=color-picker -e sh -c "${pkgs.pastel}/bin/pastel color '$PICKED'; echo; read -n 1 -s -r -p 'Press any key to close...'"
                fi
              ''}; exit";
            }

          ]
          ++ lib.optionals fsel.enable [
            {
              description = "apps";
              prefix = "search";
              cmd = resize 450 650 ''`fsel --launch-prefix='app2unit --' -vv -d -r -ss "{}"`'';
              with_argument = true;
            }
            {
              description = "launch";
              prefix = "app";
              cmd = ''fsel --launch-prefix='app2unit --' -vv -d -r -p "{}"'';
              with_argument = true;
            }
          ];
      };
      forte.fsel = {
        enable = true;
        settings = with scheme.withHashtag; {
          main_border_color = base0F;
          apps_border_color = base0F;
          input_border_color = base0E;

          main_text_color = base05;
          apps_text_color = base04;
          input_text_color = base0E;

          highlight_color = base0D;
          header_title_color = base0F;

          pin_color = base0E;
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
        };
      };

      forte.lib.otter-lib.otter-kitty-conf = pkgs.writeText "otter-kitty.conf" ''
        font_size               15
        background_opacity 0.7
        allow_remote_control yes
        ${lib.optionalString (theme == "dark") ''
          background_image        ${
            (pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/fleet-controller.png";
              hash = "sha256-pI4EzF6S7++rws35Ki3dD/Kt62XfNdmf0fuWyXCccVc=";
            })
          }
          background_image_layout scaled
          background_image_linear yes
          window_padding_width    20 105 20 105
        ''}
      '';
      forte.hyprland.lua = {
        keybinds = # lua
          ''
            hl.bind(mainMod .. " + Space", function()
              local win = hl.get_window("class:otter-launcher")
              if win then
                hl.dispatch(hl.dsp.window.close({ window = win }))
              else
                hl.dispatch(hl.dsp.exec_raw("kitty --app-id=otter-launcher -c ${config.forte.lib.otter-lib.otter-kitty-conf} -e otter-launcher"))
              end
            end)
          '';
        window-rules = # lua
          ''
            hl.window_rule({
              name         = "otter-launcher",
              match        = { class = "otter-launcher" },
              size         = ${if theme == "dark" then "{ 885, 410 }" else "{ 620, 385 }"},
              center       = true,
              float        = true,
              stay_focused = true,
              pin          = true,
              opacity          = "1 override",
              nearest_neighbor = true,
              ${lib.optionalString (theme == "dark") ''
                rounding = 20,
                rounding_power   = 10,
                border_size      = 0,
                no_shadow        = true,
              ''}
            })

            hl.window_rule({
              name         = "hyprpicker",
              match        = { class = "color-picker" },
              size         = { 670, 300 },
              center       = true,
              float        = true,
              stay_focused = true,
              pin          = true,
              opacity          = "1 override",
            })
          '';
      };
    };

  envoy.otter-launcher.github = "kuokuo123/otter-launcher";
  m.default =
    {
      self',
      birdee,
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.forte.otter-launcher;
      fsel = config.forte.fsel;
      toml = pkgs.formats.toml { };
    in
    {
      options.forte.otter-launcher = {
        enable = lib.mkEnableOption "otter-launcher";

        settings = lib.mkOption {
          inherit (toml) type;
          default = { };
          description = "Options to go into otter-launcher's toml config";
        };

        modules = lib.mkOption {
          type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
          default = [ ];
        };

        moreCfg = lib.mkOption {
          type = with lib.types; nullOr (either path lines);
          default = "";
          description = "Additional config lines.";
          example = lib.literalExpression "./config.toml";
        };

        package = lib.mkOption {
          type = lib.types.package;
          default = birdee.lib.wrapPackage (
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
                  cat ${toml.generate "config.toml" (cfg.settings // { inherit (cfg) modules; })} > "$2"
                  printf '%s\n' "${cfg.moreCfg}" >> "$2"
                '';
              };
              runtimePkgs = [
                pkgs.wiremix
                pkgs.chafa
              ]
              ++ lib.optional fsel.enable (fsel.package);
            }
          );
        };
      };
      config = lib.mkIf (cfg.enable) {
        hj.packages = [
          cfg.package
          pkgs.app2unit
        ];
        forte.lib.resize =
          width: height: app: # bash
          ''
            hyprctl --batch "dispatch hl.dsp.window.resize({ x = ${toString width}, y = ${toString height} }); dispatch hl.dsp.window.center(); dispatch hl.dsp.window.set_prop({ prop = 'rounding', value = 0 }); dispatch hl.dsp.window.set_prop({ prop = 'no_shadow', value = false }); dispatch hl.dsp.window.set_prop({ prop = 'border_size', value = 9 })" \
            && kitten @ set-background-image none \
            && kitten @ set-spacing padding=0 \
            && kitten @ set-font-size ${toString config.forte.kitty.fontConfig.font_size} \
            && ${app}
          '';
      };
    };

  perSystem =
    { pkgs, envoy, ... }:
    {
      packages = {
        otter-launcher = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
          inherit (envoy.otter-launcher) pname version src;
          cargoLock.lockFile = finalAttrs.src + "/Cargo.lock";
          doCheck = false;
          patches = [
            (pkgs.writeText "selection.patch" # rust
              ''
                diff --git a/src/helper.rs b/src/helper.rs
                index 991b6bf..248f856 100644
                --- a/src/helper.rs
                +++ b/src/helper.rs
                @@ -463,6 +463,10 @@ impl Hinter for OtterHelper {
                             // make the number of filtered items globally accessible
                             FILTERED_HINT_COUNT.store(filtered_items.len(), Ordering::Relaxed);

                +            if !line.is_empty() && selection_index == 0 && !filtered_items.is_empty() {
                +                SELECTION_INDEX.store(1, Ordering::Relaxed);
                +            }
                +
                             // Check if there are enough filtered items after the skip
                             let agg_line = if hint_benchmark + suggestion_lines
                                 > FILTERED_HINT_COUNT.load(Ordering::Relaxed)
                --
                2.53.0
              ''
            )
          ];
        });
      };
    };
}
