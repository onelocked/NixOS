{
  m.niri =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      forte.niri = {
        enable = true;
        withUWSM = true;
        withGreetd = true;
        withTermFileChooser = true;
        hotReload = true;
        settings =
          let
            set = _: { };
          in
          {
            # General Niri Settings
            prefer-no-csd = true;
            clipboard.disable-primary = true;
            spawn-sh-at-startup = [
              "${pkgs.libsecret}/bin/secret-tool lookup app keyring-init || echo 'init' | secret-tool store --label='keyring-init' app keyring-init"
            ];

            xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

            outputs."HDMI-A-1" = {
              mode = "3440x1440@99.982";
              scale = 1;
              transform = "normal";
              position = _: {
                props = {
                  x = 0;
                  y = 0;
                };
                content = { };
              };
            };

            window-rule = {
              clip-to-geometry = true;
              draw-border-with-background = false;
              geometry-corner-radius = 0;
              open-fullscreen = false;
              open-maximized = false;
            };

            window-rules = [
              {
                matches = [ { title = "Select what to share"; } ];
                open-floating = true;
                default-column-width.fixed = 500;
                default-window-height.fixed = 290;
                max-width = 500;
                max-height = 290;
              }
            ];

            overview = {
              zoom = 0.35;
              workspace-shadow.off = set;
            };

            hotkey-overlay.skip-at-startup = set;

            screenshot-path =
              config.hj.directory + "/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

            debug = {
              honor-xdg-activation-with-invalid-serial = set;
              strict-new-window-focus-policy = set;
            };

            recent-windows = {
              debounce-ms = 750;
              open-delay-ms = 250;
              highlight = {
                active-color = "#c5c0ff";
                urgent-color = "#ffb4ab";
                padding = 15;
                corner-radius = 20;
              };
              previews = {
                max-height = 480;
                max-scale = 0.5;
              };
            };

            input = {
              mod-key = "Super";
              mod-key-nested = "Alt";
              disable-power-key-handling = set;
              keyboard = {
                repeat-rate = 40;
                repeat-delay = 370;
                xkb = {
                  layout = "us,ru";
                };
                track-layout = "global";
              };
              mouse = {
                accel-profile = "flat";
                natural-scroll = set;
                scroll-factor = 1.2;
                scroll-method = "on-button-down";
                scroll-button = 273;
                scroll-button-lock = set;
              };
            };

            cursor = {
              xcursor-theme = config.custom.gtk.cursor.name;
              xcursor-size = lib.toInt config.custom.gtk.cursor.size;
            };

            gestures.hot-corners.off = set;

            layout = {
              empty-workspace-above-first = set;
              background-color = "transparent";
              always-center-single-column = set;
              gaps = 20;
              center-focused-column = "on-overflow";
              preset-column-widths = [
                { fixed = 2489; }
                { fixed = 871; }
              ];
              default-column-width.fixed = 2489;
              focus-ring = {
                off = set;
                width = 1;
                active-color = "#5a468c";
                inactive-color = "#191919";
                urgent-color = "#ffb4ab";
              };
              border = {
                on = set;
                width = 5;
                active-color = "#a898c8";
                inactive-color = "#b4b4b4";
                urgent-color = "#f0b8d0";
              };
              shadow = {
                on = set;
                draw-behind-window = false;
                softness = 0;
                spread = 0;
                offset = _: {
                  props = {
                    x = 8;
                    y = 9;
                  };
                  content = { };
                };
                color = "#302453E6";
                inactive-color = "#302453E6";
              };
              tab-indicator = {
                active-color = "#c5c0ff";
                inactive-color = "#413b8e";
                urgent-color = "#ffb4ab";
              };
              insert-hint = {
                color = "#c5c0ff80";
              };
              struts = {
                left = -5;
                right = -5;
                top = 30;
                bottom = 15;
              };
            };

            # Niri Keybinds
            binds = {
              # Unbind side mouse buttons
              "MouseBack" = _: {
                props = {
                  repeat = false;
                };
                content = {
                  spawn = set;
                };
              };
              "MouseForward" = _: {
                props = {
                  repeat = false;
                };
                content = {
                  spawn = set;
                };
              };

              # Window Actions
              "Mod+G" = _: {
                props = {
                  repeat = false;
                };
                content = {
                  toggle-overview = set;
                };
              };
              "Mod+Q" = _: {
                props = {
                  repeat = false;
                };
                content = {
                  close-window = set;
                };
              };

              # Navigation
              "Mod+Left".focus-column-left = set;
              "Mod+Down".focus-window-down = set;
              "Mod+Up".focus-window-up = set;
              "Mod+Right".focus-column-right = set;

              # Moving Windows
              "Mod+Ctrl+Left".move-column-left = set;
              "Mod+Ctrl+Down".move-window-down = set;
              "Mod+Ctrl+Up".move-window-up = set;
              "Mod+Ctrl+Right".move-column-right = set;

              # Mouse Wheel Navigation
              "Mod+WheelScrollDown" = _: {
                props = {
                  cooldown-ms = 150;
                };
                content = {
                  focus-column-right = set;
                };
              };
              "Mod+WheelScrollUp" = _: {
                props = {
                  cooldown-ms = 150;
                };
                content = {
                  focus-column-left = set;
                };
              };

              "Mod+Shift+WheelScrollDown" = _: {
                props = {
                  cooldown-ms = 150;
                };
                content = {
                  focus-workspace-down = set;
                };
              };
              "Mod+Shift+WheelScrollUp" = _: {
                props = {
                  cooldown-ms = 150;
                };
                content = {
                  focus-workspace-up = set;
                };
              };

              # Workspaces
              "Mod+1".focus-workspace = "browser";
              "Mod+2".focus-workspace = "coding";
              "Mod+3".focus-workspace = "social";
              "Mod+4".focus-workspace = "media";
              "Mod+5".focus-workspace = 5;
              "Mod+6".focus-workspace = 6;
              "Mod+7".focus-workspace = 7;
              "Mod+8".focus-workspace = 8;
              "Mod+9".focus-workspace = 9;

              "Mod+Shift+1".move-column-to-workspace = "browser";
              "Mod+Shift+2".move-column-to-workspace = "coding";
              "Mod+Shift+3".move-column-to-workspace = "social";
              "Mod+Shift+4".move-column-to-workspace = "media";
              "Mod+Shift+5".move-column-to-workspace = 5;
              "Mod+Shift+6".move-column-to-workspace = 6;
              "Mod+Shift+7".move-column-to-workspace = 7;
              "Mod+Shift+8".move-column-to-workspace = 8;
              "Mod+Shift+9".move-column-to-workspace = 9;

              # Layout Manipulation
              "Mod+BracketLeft".consume-or-expel-window-left = set;
              "Mod+BracketRight".consume-or-expel-window-right = set;

              "Mod+R".switch-preset-column-width = set;
              "Mod+Ctrl+R".reset-window-height = set;
              "Mod+F".maximize-column = set;
              "Mod+M".fullscreen-window = set;
              "Mod+Shift+F".toggle-windowed-fullscreen = set;
              "Mod+C".center-column = set;

              "Mod+Minus".set-column-width = "-10%";
              "Mod+Equal".set-column-width = "+10%";

              "Mod+Shift+Minus".set-window-height = "-10%";
              "Mod+Shift+Equal".set-window-height = "+10%";

              "Mod+W".expand-column-to-available-width = set;
              "Mod+SHIFT+W".toggle-window-floating = set;

              # Screenshot
              "Print".screenshot = set;
            };
            workspacesList = [
              {
                name = "browser";
                config = {
                  # Ensure things map cleanly as sub-nodes matching Niri expectations
                  layout = {
                    center-focused-column = "never";
                    default-column-width = {
                      fixed = 2390;
                    };
                    preset-column-widths = [
                      { fixed = 2390; }
                      { fixed = 2735; }
                    ];
                  };
                };
              }
              {
                name = "coding";
                config = {
                  layout = {
                    center-focused-column = "never";
                    default-column-width = {
                      fixed = 2488;
                    };
                    preset-column-widths = [
                      { proportion = 0.5; }
                      { fixed = 2488; }
                    ];
                  };
                };
              }
              {
                name = "social";
                config = {
                  layout = {
                    center-focused-column = "never";
                    preset-column-widths = [
                      { proportion = 0.79; }
                      { proportion = 0.21; }
                    ];
                  };
                };
              }
              {
                name = "media";
                config = {
                  layout = {
                    center-focused-column = "never";
                    default-column-width = {
                      proportion = 0.749;
                    };
                    preset-column-widths = [
                      { proportion = 0.749; }
                    ];
                  };
                };
              }
            ];
            extraConfig =
              lib.mkAfter # kdl
                ''include optional=true "${config.hj.xdg.config.directory}/niri/config.kdl"; '';
          };
      };
    };
  m.default =
    {
      birdee,
      pkgs,
      config,
      lib,
      self',
      constants,
      ...
    }:
    let
      cfg = config.forte.niri;
    in
    {
      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            hj.packages = [ cfg.package ];
            xdg.portal = {
              configPackages = [ cfg.package ];
              config = {
                niri = {
                  default = lib.mkForce [ "gnome" ];
                  "org.freedesktop.impl.portal.FileChooser" = lib.mkForce (
                    if cfg.withTermFileChooser then [ "termfilechooser" ] else [ "gtk" ]
                  );
                  "org.freedesktop.impl.portal.Secret" = lib.mkForce [ "gnome-keyring" ];
                  "org.freedesktop.impl.portal.Chooser" = lib.mkForce [ "none" ];
                };
              };
              extraPortals = [
                pkgs.xdg-desktop-portal-gnome
              ]
              ++ lib.optional (!cfg.withTermFileChooser) pkgs.xdg-desktop-portal-gtk;
            };
            services.graphical-desktop.enable = true;
            services.speechd.enable = lib.mkForce false;
          }
          (lib.mkIf cfg.withGreetd {
            services = {
              displayManager.enable = lib.mkForce false;
              greetd = {
                enable = true;
                settings = {
                  default_session = {
                    command =
                      if cfg.withUWSM then
                        "${lib.getExe config.programs.uwsm.package} start niri-uwsm.desktop"
                      else
                        "${lib.getExe' cfg.package "niri-session"}";
                    user = constants.username;
                  };
                };
              };
            };
          })
          (lib.mkIf cfg.hotReload {
            system.userActivationScripts = {
              niri-reload-config = {
                text = lib.getExe (
                  pkgs.writeShellApplication (
                    let
                      inherit (cfg) package;
                      inherit (package.configuration.constructFiles.generatedConfig) outPath;
                    in
                    {
                      name = "niri-reload-config";
                      runtimeInputs = [
                        package
                        pkgs.procps
                      ];
                      text = ''
                        if pgrep -x "niri" > /dev/null; then
                          niri msg action load-config-file --path "${outPath}"
                        fi
                      '';
                    }
                  )
                );
              };
            };
          })
          (lib.mkIf cfg.withUWSM {
            forte.xdg.desktopEntries."uuctl".noDisplay = true;
            programs.uwsm = {
              enable = true;
              waylandCompositors = {
                niri = {
                  prettyName = "niri";
                  comment = "Niri compositor managed by UWSM";
                  binPath = "${lib.getExe cfg.package}";
                  extraArgs = [ "--session" ];
                };
              };
            };
          })
          (lib.mkIf (!cfg.withUWSM) {
            services.displayManager.sessionPackages = [ cfg.package ];
          })
          (lib.mkIf (config.forte.startup != [ ]) {
            forte.niri.settings = lib.mkMerge (
              config.forte.startup
              |> lib.filter (startup: startup.enable)
              |> map (startup: {
                spawn-at-startup = [ startup.spawn ];
                window-rules = lib.optional (startup.app-id != null) (
                  {
                    matches = [ { inherit (startup) app-id; } ];
                  }
                  // (lib.optionalAttrs (startup.workspace != null) {
                    open-on-workspace = toString startup.workspace;
                  })
                  // startup.niriArgs
                );
              })
            );
          })
        ]
      );
      options = {
        forte.niri = {
          enable = lib.mkEnableOption "Niri, a scrollable-tiling Wayland compositor";
          package = lib.mkOption {
            type = lib.types.package;
            default = birdee.wrappers.niri.wrap (
              { wlib, config, ... }:
              let
                convertToKdl = v: v;
                mkRule =
                  node: r:
                  let
                    matches = map (m: { match = _: { props = m; }; }) (r.matches or [ ]);
                    excludes = map (m: { exclude = _: { props = m; }; }) (r.excludes or [ ]);
                    other = lib.mapAttrsToList (n: v: { ${n} = v; }) (
                      lib.attrsets.removeAttrs r [
                        "matches"
                        "excludes"
                      ]
                    );
                  in
                  {
                    ${node} = matches ++ excludes ++ other;
                  };
                attrAsArg =
                  node:
                  lib.mapAttrsToList (
                    n: v: {
                      ${node} =
                        s:
                        if lib.isFunction v then
                          let
                            res = v s;
                          in
                          res
                          // {
                            props =
                              if res ? props then
                                if builtins.isAttrs res.props then
                                  [
                                    n
                                    res.props
                                  ]
                                else if builtins.isList res.props then
                                  [ n ] ++ res.props
                                else
                                  n
                              else
                                n;
                          }
                        else if builtins.isAttrs v then
                          {
                            content = v;
                            props = n;
                          }
                        else
                          { props = n; };
                    }
                  );
              in
              {
                config = {
                  inherit pkgs;
                  package = self'.packages.niri;
                  v2-settings = true;
                  disableConfigHotReload = true;
                  inherit (cfg) settings;
                  env.NIRI_CONFIG = lib.mkForce config.constructFiles.generatedConfig.path;
                  constructFiles.generatedConfig = lib.mkForce {
                    relPath = "config.kdl";
                    content =
                      wlib.toKdl (_: {
                        version = 1;
                        content = builtins.concatLists [
                          (map (v: { spawn-at-startup = _: { props = v; }; }) config.settings.spawn-at-startup)
                          (map (v: { spawn-sh-at-startup = _: { props = v; }; }) config.settings.spawn-sh-at-startup)
                          (attrAsArg "output" config.settings.outputs)
                          (attrAsArg "workspace" config.settings.workspaces)
                          (map (w: {
                            workspace =
                              s:
                              let
                                v = w.config;
                                res =
                                  if lib.isFunction v then
                                    v s
                                  else
                                    {
                                      content = v;
                                      props = w.name;
                                    };
                              in
                              res // { props = w.name; };
                          }) config.settings.workspacesList)
                          [
                            (convertToKdl (
                              lib.removeAttrs config.settings [
                                "window-rules"
                                "layer-rules"
                                "spawn-at-startup"
                                "spawn-sh-at-startup"
                                "workspacesList"
                                "workspaces"
                                "outputs"
                                "extraConfig"
                              ]
                            ))
                          ]
                          config.extraSettings
                          (map (mkRule "window-rule") config.settings.window-rules)
                          (map (mkRule "layer-rule") config.settings.layer-rules)
                        ];
                      })
                      + "\n"
                      + config.settings.extraConfig;
                  };
                };
                options.settings.workspacesList = lib.mkOption {
                  default = [ ];
                  type = lib.types.listOf (
                    lib.types.submodule {
                      options = {
                        name = lib.mkOption {
                          type = lib.types.str;
                          description = "Workspace name (determines index order)";
                        };
                        config = lib.mkOption {
                          type = lib.types.anything;
                          default = _: { };
                          description = "Workspace config, same format as `workspaces` values";
                        };
                      };
                    }
                  );
                };
              }
            );
            defaultText = lib.literalExpression "wrapped niri";
            description = "Niri package to use.";
          };
          withUWSM = lib.mkEnableOption null // {
            description = ''
              Launch Niri with the UWSM (Universal Wayland Session Manager) session manager.
              This has improved systemd support.
              This automatically starts appropriate targets like `graphical-session.target`,
              and `wayland-session@Niri.target`.
            '';
          };
          withGreetd = lib.mkEnableOption null // {
            description = ''
              Whether to enable greetd as the login manager for the niri Wayland compositor,
            '';
          };
          withTermFileChooser = lib.mkEnableOption null // {
            description = ''
              Whether to enable xdg-termfilechooser settings for niri,
            '';
          };
          hotReload = lib.mkEnableOption null // {
            description = ''
              Whether to enable hot-reloading of niri config.
            '';
          };
          settings = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              freeformType = lib.types.attrs;
              options = {
                binds = lib.mkOption {
                  default = { };
                  type = lib.types.attrs;
                };
                layout = lib.mkOption {
                  default = { };
                  type = lib.types.attrs;
                };
                spawn-at-startup = lib.mkOption {
                  default = [ ];
                  type = lib.types.listOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
                };
                window-rules = lib.mkOption {
                  default = [ ];
                  type = lib.types.listOf lib.types.attrs;
                };
                layer-rules = lib.mkOption {
                  default = [ ];
                  type = lib.types.listOf lib.types.attrs;
                };
                workspacesList = lib.mkOption {
                  default = [ ];
                  type = lib.types.listOf (
                    lib.types.submodule {
                      options = {
                        name = lib.mkOption {
                          type = lib.types.str;
                          description = "Workspace name (determines index order)";
                        };
                        config = lib.mkOption {
                          type = lib.types.anything;
                          default = _: { };
                          description = "Workspace config, same format as `workspaces` values";
                        };
                      };
                    }
                  );
                };
                outputs = lib.mkOption {
                  default = { };
                  type = lib.types.attrs;
                };
                # change to lines to allow merging
                extraConfig = lib.mkOption {
                  default = "";
                  type = lib.types.lines;
                };
              };
            };
          };
        };
        forte.startup = lib.mkOption {
          description = "Programs to run on startup";
          default = [ ];
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                app-id = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
                enable = lib.mkEnableOption "Startup program" // {
                  default = true;
                };
                spawn = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                };
                workspace = lib.mkOption {
                  type = lib.types.nullOr (lib.types.either lib.types.int lib.types.str);
                  default = null;
                };
                niriArgs = lib.mkOption {
                  type = lib.types.attrs;
                  default = { };
                };
              };
            }
          );
        };
      };
    };
  ff = {
    niri = {
      url = "github:niri-wm/niri/b82d52705e1424cf47b26dd7b096832901c31f56";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  perSystem =
    { inputs', ... }:
    {
      packages.niri = inputs'.niri.packages.default.overrideAttrs { doCheck = false; };
    };
}
