{
  lib,
  inputs,
  self,
  ...
}:
{
  ff = {
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        vicinae.follows = "vicinae";
        systems.follows = "systems";
      };
    };
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        vicinae.follows = "vicinae";
        systems.follows = "systems";
      };
    };
  };

  m.vicinae =
    { pkgs, config, ... }:
    {
      nixpkgs.overlays = [ inputs.vicinae.overlays.default ];

      nix.settings = {
        extra-substituters = [ "https://vicinae.cachix.org" ];
        extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
      };

      custom.services.vicinae = {
        enable = true;
        systemd = {
          enable = false;
          autoStart = false;
          environment = {
            USE_LAYER_SHELL = 1;
          };
        };

        settings = {
          telemetry.system_info = false;
          close_on_focus_loss = true;
          consider_preedit = true;
          activate_on_single_click = true;
          pop_to_root_on_close = true;
          favicon_service = "twenty";
          search_files_in_root = false;
          font = {
            normal = {
              family = "SF Pro Text";
              size = 14;
            };
          };
          theme = {
            dark = {
              name = "noctalia";
              icon_theme = "Papirus";
            };
          };
          launcher_window = {
            opacity = 1;
            blur.enabled = false;

            client_side_decorations = {
              enabled = true;
              rounding = 20;
              border_width = 1;
            };

            compact_mode.enabled = false;

          };

          favorites = [
            "applications:zen-twilight"
            "applications:com.obsproject.Studio"
            "applications:com.ayugram"
            "applications:spotify"
            "applications:com.moonlight_stream.Moonlight"
            "applications:parsecd"
            "applications:vesktop"
            "applications:dev.lizardbyte.app.Sunshine"
            "applications:org.jellyfin.JellyfinDesktop"
          ];
          providers = {
            "@knoopx/store.vicinae.nix" = {
              enabled = true;
              entrypoints = {
                "home-manager-options" = {
                  alias = "hm";
                };
                "options" = {
                  alias = "no";
                };
                "packages" = {
                  alias = "np";
                };
                "pull-requests" = {
                  enabled = false;
                };
              };
            };

            applications = {
              preferences = {
                paths = [
                  "${config.hj.xdg.data.directory}/share/applications"
                  "/etc/profiles/per-user/${self.variables.username}/share/applications"
                  "/run/current-system/sw/share/applications"
                ];
                defaultAction = "focus";
                launchPrefix = "uwsm app --";
              };
            };

            "browser-extension".enabled = false;

            clipboard.preferences.monitoring = true;

            core.enabled = true;

            developer.enabled = false;

            files = {
              enabled = false;
              preferences = {
                paths = "/home/onelock/Pictures";
              };
            };

            font.enabled = false;

            "manage-shortcuts".enabled = false;

            power.enabled = false;

            "raycast-compat".enabled = true;

            system.enabled = false;

            theme.enabled = false;

            wm.enabled = false;
          };

        };
        extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [ nix ];
      };
    };

  m.default =
    { pkgs, config, ... }:
    let
      cfg = config.custom.services.vicinae;

      jsonFormat = pkgs.formats.json { };
      tomlFormat = pkgs.formats.toml { };
    in
    {

      options.custom.services.vicinae = {
        enable = lib.mkEnableOption "vicinae launcher daemon";

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.vicinae;
          defaultText = lib.literalExpression "vicinae";
          description = "The vicinae package to use";
        };

        systemd = {
          enable = lib.mkEnableOption "vicinae systemd integration";

          autoStart = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "If the vicinae daemon should be started automatically";
          };

          environment = lib.mkOption {
            type =
              with lib.types;
              let
                valueType = attrsOf (oneOf [
                  str
                  int
                  float
                  bool
                ]);
              in
              valueType;
            default = { };
            description = "Environment variables for the vicinae daemon. See <https://docs.vicinae.com/launcher-window#wayland-layer-shell>";
            example = lib.literalExpression ''
              {
                USE_LAYER_SHELL=1;
                QT_SCALE_FACTOR=1.5;
              }
            '';
          };

          target = lib.mkOption {
            type = lib.types.str;
            default = "graphical-session.target";
            example = "sway-session.target";
            description = ''
              The systemd target that will automatically start the vicinae service.
            '';
          };
        };

        extensions = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = ''
            List of Vicinae extensions to install.
            You can use the `mkVicinaeExtension` function from the overlay to create extensions.
          '';
        };

        themes = lib.mkOption {
          inherit (tomlFormat) type;
          default = { };
          description = ''
            Theme settings to add to the themes folder in `~/.config/vicinae/themes`. See <https://docs.vicinae.com/theming/getting-started> for supported values.

            The attribute name of the theme will be the name of theme file,
          '';
          example =
            lib.literalExpression # nix
              ''
                {
                  catppuccin-mocha = {
                    meta = {
                      version = 1;
                      name = "Catppuccin Mocha";
                      description = "Cozy feeling with color-rich accents";
                      variant = "dark";
                      icon = "icons/catppuccin-mocha.png";
                      inherits = "vicinae-dark";
                    };

                    colors = {
                      core = {
                        background = "#1E1E2E";
                        foreground = "#CDD6F4";
                        secondary_background = "#181825";
                        border = "#313244";
                        accent = "#89B4FA";
                      };
                      accents = {
                        blue = "#89B4FA";
                        green = "#A6E3A1";
                        magenta = "#F5C2E7";
                        orange = "#FAB387";
                        purple = "#CBA6F7";
                        red = "#F38BA8";
                        yellow = "#F9E2AF";
                        cyan = "#94E2D5";
                      };
                    };
                  };
                }
              '';
        };

        settingOverrides = lib.mkOption {
          type = lib.types.listOf lib.types.path;
          default = [ ];
          example =
            lib.literalExpression # nix
              ''
                [
                  ${config.xdg.configHome}/vicinae/override.json
                  /run/secrets/vicinae-secrets.json
                ]
              '';
          description = ''
            Allows you to specify additional JSON files that will be merged with the imperative settings and take precedence.
          '';
        };

        settings = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
          description = ''
            Settings written as JSON to `~/.config/vicinae/nix.json`.
            This is will override any settings from the default settings.json.
            The easiest way to configure this is first configuring your settings in the app,
            then copying the generated `~/.config/vicinae/settings.json` to `~/.config/vicinae/nix.json` and then modifying it as needed.
            If you want to set secrets you should import these files using the settingOverrides option.
          '';
          example = lib.literalExpression ''
            {
              close_on_focus_loss = true;
              consider_preedit = true;
              pop_to_root_on_close = true;
              favicon_service = "twenty";
              search_files_in_root = true;
              font = {
                normal = {
                  size = 12;
                  family = "Maple Nerd Font";
                };
              };
              theme = {
                light = {
                  name = "vicinae-light";
                  icon_theme = "default";
                };
                dark = {
                  name = "vicinae-dark";
                  icon_theme = "default";
                };
              };
              launcher_window = {
                opacity = 0.98;
              };
            }
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        hj = {
          packages = [ cfg.package ];

          xdg =
            let
              themeFiles =
                cfg.themes
                |> lib.mapAttrs' (
                  name: theme:
                  lib.nameValuePair "vicinae/themes/${name}.toml" {
                    source = tomlFormat.generate "vicinae-${name}-theme" theme;
                  }
                );
            in
            {
              config.files = {
                "vicinae/nix.json" = lib.mkIf (cfg.settings != { }) {
                  source = jsonFormat.generate "vicinae-settings" cfg.settings;
                };
              };

              data.files =
                (
                  cfg.extensions
                  |> map (item: {
                    name = "vicinae/extensions/${item.name}";
                    value.source = item;
                  })
                  |> builtins.listToAttrs
                )
                // themeFiles;
            };

          systemd.services.vicinae = lib.mkIf cfg.systemd.enable {
            description = "Vicinae server daemon";
            documentation = [ "https://docs.vicinae.com" ];
            after = [ cfg.systemd.target ];
            partOf = [ cfg.systemd.target ];
            environment =
              cfg.systemd.environment
              // (lib.mkIf (cfg.settings != { }) {
                VICINAE_OVERRIDES = "${config.hj.xdg.config.directory}/vicinae/nix.json";
              })
              // (lib.mkIf (cfg.settingOverrides != [ ]) {
                VICINAE_OVERRIDES = "${lib.concatStringsSep ":" cfg.settingOverrides}";
              });

            serviceConfig = {
              Type = "simple";
              ExecStart = "${lib.getExe' cfg.package "vicinae"} server";
              Restart = "always";
              RestartSec = 5;
              KillMode = "process";
            };
            wantedBy = lib.mkIf cfg.systemd.autoStart [ cfg.systemd.target ];
          };
        };
      };
    };
}
