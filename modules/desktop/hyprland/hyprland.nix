{
  ff.hyprland = {
    url = "github:hyprwm/Hyprland";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.systems.follows = "systems";
  };

  exo.mods.desktop = {
    forte.hyprland = {
      enable = true;
      withUWSM = true;
      withGreetd = true;
      withTermFileChooser = true;
    };
  };

  exo.skeleton =
    {
      lib,
      config,
      constants,
      pkgs,
      self',
      ...
    }:
    let
      pluginPath =
        entry: if lib.types.package.check entry then "${entry}/lib/lib${entry.pname}.so" else entry;

      cfg = config.forte.hyprland;

      luaFileName =
        name:
        let
          base = lib.removeSuffix ".lua" name;
        in
        builtins.replaceStrings [ "." ] [ "/" ] base + ".lua";

      requireName = name: lib.removeSuffix ".lua" name;

      autoLoadFiles = lib.filterAttrs (_: file: file.autoLoad) cfg.lua;
    in
    {
      config =
        lib.mkIf cfg.enable
        <| lib.mkMerge [
          {
            hj.packages = [
              cfg.package
              pkgs.hyprshutdown
            ];
            environment.sessionVariables = {
              AQ_NO_MODIFIERS = 1;
            };
            forte.hyprland.lua.settings =
              lib.optionalString (cfg.plugins != [ ]) # lua
                ''
                  hl.on("hyprland.start", function ()
                    ${lib.concatMapStrings (entry: ''
                      hl.exec_raw("hyprctl plugin load ${pluginPath entry}")
                    '') cfg.plugins}
                  end)
                '';
            hj.xdg.config.files = lib.mkMerge [
              (lib.mkIf (autoLoadFiles != { }) {
                "hypr/hyprland.lua".text =
                  let
                    priority = [ "settings" ];
                    rank = name: lib.lists.findFirstIndex (x: x == name) (lib.length priority) priority;
                  in
                  autoLoadFiles
                  |> lib.mapAttrsToList (name: _: name)
                  |> builtins.sort (
                    a: b:
                    let
                      ra = rank a;
                      rb = rank b;
                    in
                    if ra != rb then ra < rb else a < b
                  )
                  |> map (name: ''require("${requireName name}")'')
                  |> (
                    lines:
                    lines
                    ++ [
                      #lua
                      ''
                        if is_file_exists("${config.hj.xdg.config.directory}/hypr/dynamic.lua") then
                            require("dynamic")
                        end
                      ''
                    ]
                  )
                  |> lib.concatLines;
              })
              (
                cfg.lua
                |> lib.mapAttrs' (
                  name: file:
                  lib.nameValuePair "hypr/${luaFileName name}" (
                    if builtins.isPath file.content then { source = file.content; } else { text = file.content; }
                  )
                )
              )
              {
                # Needed for lua stub file
                "hypr/.luarc.json".text = # json
                  ''
                    {
                      "workspace": {
                        "library": [
                          "${cfg.package}/share/hypr/stubs"
                        ]
                      }
                    }
                  '';
              }
            ];
            services.graphical-desktop.enable = true;
            services.speechd.enable = lib.mkForce false;

            programs.xwayland.enable = true;

            systemd.user.extraConfig = ''DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH" '';
            xdg.portal = {
              wlr.enable = false;
              enable = true;
              extraPortals = [
                cfg.portalPackage
                pkgs.xdg-desktop-portal-gtk
              ];
              configPackages = lib.mkDefault [ cfg.package ];
            };
            security.wrappers.Hyprland = {
              owner = "root";
              group = "root";
              capabilities = "cap_sys_nice+ep";
              source = lib.getExe cfg.package;
            };
          }
          (lib.mkIf cfg.withGreetd {
            services = {
              displayManager.enable = lib.mkForce false;
              greetd = {
                enable = true;
                settings.default_session = {
                  command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
                  user = constants.username;
                };
              };
            };
          })
          (lib.mkIf cfg.withTermFileChooser {
            xdg.portal.config.hyprland = {
              default = lib.mkForce [
                "hyprland"
                "gtk"
              ];
              "org.freedesktop.impl.portal.FileChooser" = lib.mkForce [ "termfilechooser" ];
              "org.freedesktop.impl.portal.Secret" = lib.mkForce [ "gnome-keyring" ];
              "org.freedesktop.impl.portal.Chooser" = lib.mkForce [ "none" ];
            };
          })
          (lib.mkIf (cfg.withUWSM) {
            forte.xdg.desktopEntries."uuctl".noDisplay = true;
            programs.uwsm.enable = true;
          })
        ];
      options.forte.hyprland = {
        enable = lib.mkEnableOption ''
          Hyprland, the dynamic tiling Wayland compositor that doesn't sacrifice on its looks.
          You can manually launch Hyprland by executing {command}`start-hyprland` on a TTY.
          A configuration file will be generated in {file}`~/.config/hypr/hyprland.conf`.
          See <https://wiki.hyprland.org> for more information'';

        package = lib.mkOption {
          type = lib.types.package;
          default = self'.packages.hyprland;
        };

        portalPackage = lib.mkOption {
          type = lib.types.package;
          default = self'.packages.xdg-desktop-portal-hyprland;
        };

        plugins = lib.mkOption {
          type = with lib.types; listOf (either package path);
          default = [ ];
          description = ''
            List of Hyprland plugins to use. Can either be packages or
            absolute plugin paths.
          '';
        };

        withUWSM = lib.mkEnableOption null // {
          description = ''
            Launch Hyprland with the UWSM (Universal Wayland Session Manager) session manager.
            This has improved systemd support and is recommended for most users.
            This automatically starts appropriate targets like `graphical-session.target`,
            and `wayland-session@Hyprland.target`.

            ::: {.note}
            Some changes may need to be made to Hyprland configs depending on your setup, see
            [Hyprland wiki](https://wiki.hyprland.org/Useful-Utilities/Systemd-start/#uwsm).
            :::
          '';
        };

        lua = lib.mkOption {
          type =
            with lib.types;
            attrsOf (
              coercedTo (either path lines)
                (content: {
                  inherit content;
                  autoLoad = true;
                })
                (submodule {
                  options = {
                    content = lib.mkOption {
                      type = either path lines;
                      description = ''
                        Lua file content, either as a multi-line string or a path to a .lua file.
                      '';
                    };
                    autoLoad = lib.mkOption {
                      type = bool;
                      default = true;
                      description = ''
                        Whether to generate a require() call for this file in hyprland.lua.
                        Set to false for helper modules imported by other Lua files.
                      '';
                    };
                  };
                })
            );
          default = { };
          description = ''
            Lua files written to $XDG_CONFIG_HOME/hypr.

            Attribute names become file names: dots become directory separators and
            .lua is appended if missing. For example, "lib.helpers" writes
            hypr/lib/helpers.lua and "settings" writes hypr/settings.lua.

            Files with autoLoad = true are require()'d in hyprland.lua in
            alphabetical order. Use numeric prefixes (e.g. "00-variables",
            "01-settings") to control load order.
          '';
        };

        withGreetd = lib.mkEnableOption null // {
          description = ''
            Whether to enable greetd as the login manager for Hyprland.
          '';
        };

        withTermFileChooser = lib.mkEnableOption null // {
          description = ''
            Whether to enable xdg-termfilechooser settings for Hyprland.
          '';
        };
      };
    };
  perSystem =
    { inputs', ... }:
    {
      packages = {
        hyprland = inputs'.hyprland.packages.hyprland.overrideAttrs { doCheck = false; };
        xdg-desktop-portal-hyprland = inputs'.hyprland.packages.xdg-desktop-portal-hyprland.overrideAttrs {
          doCheck = false;
        };
      };
    };
}
