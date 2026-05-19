{
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
  m.niri = {
    forte.niri = {
      enable = true;
      withUWSM = true;
      withGreetd = true;
      withTermFileChooser = true;
      hotReload = true;
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
            default = birdee.wrappers.niri.wrap {
              inherit pkgs;
              package = self'.packages.niri;
              v2-settings = true;
              disableConfigHotReload = true;
              inherit (config.forte.niri) settings;
            };
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
                workspaces = lib.mkOption {
                  default = { };
                  type = lib.types.attrsOf (lib.types.nullOr lib.types.anything);
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
  perSystem =
    { inputs', ... }:
    {
      packages.niri = inputs'.niri.packages.default.overrideAttrs { doCheck = false; };
    };
}
