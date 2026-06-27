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
      withHyprpolkit = true;
    };
  };

  exo.skeleton =
    {
      lib,
      config,
      constants,
      pkgs,
      self',
      hardware,
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
            forte.persist.home.directories = [ ".config/hypr" ];
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

            systemd.user.settings.Manager.DefaultEnvironment =
              "PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH";

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
            hj.systemd.services.unlock-keyring = {
              description = "Unlock GNOME Keyring on startup";
              wantedBy = [ "graphical-session.target" ];
              requires = [ "graphical-session.target" ];
              after = [ "graphical-session.target" ];
              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.writeShellScript "unlock-keyring" # bash
                  ''
                    ${pkgs.libsecret}/bin/secret-tool lookup app keyring-init || echo 'init' | ${pkgs.libsecret}/bin/secret-tool store --label='keyring-init' app keyring-init
                  ''
                }";
              };
            };
          }
          (lib.mkIf cfg.withGreetd {
            security.pam.services.greetd.enableGnomeKeyring = true;
            services = {
              displayManager.enable = lib.mkForce false;
              greetd = {
                enable = true;
                settings.default_session = {
                  command =
                    if cfg.withUWSM then
                      "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop"
                    else
                      "${cfg.package}/bin/start-hyprland";
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
              "org.freedesktop.impl.portal.AppChooser" = lib.mkForce [ "none" ];
            };
          })
          (lib.mkIf (cfg.withUWSM) {
            forte.xdg.desktopEntries."uuctl".noDisplay = true;
            programs.uwsm.enable = true;
          })
          (lib.mkIf cfg.withHyprpolkit {
            hj.systemd.services.hyprpolkitagent = {
              description = "Hyprpolkitagent - Polkit authentication agent";
              wantedBy = [ "graphical-session.target" ];
              wants = [ "graphical-session.target" ];
              after = [ "graphical-session.target" ];
              serviceConfig = {
                Type = "simple";
                ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
                Restart = "on-failure";
                RestartSec = 1;
                TimeoutStopSec = 10;
              };
            };
          })
          (lib.mkIf (hardware == "mini-pc") {
            environment.sessionVariables = {
              AQ_NO_MODIFIERS = 1;
            };
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
        withHyprpolkit = lib.mkEnableOption null // {
          description = ''
            Whether to enable hyprpolkit daemon
          '';
        };
      };
    };
  perSystem =
    { inputs', pkgs, ... }:
    {
      packages = {
        hyprland = inputs'.hyprland.packages.hyprland.overrideAttrs (oldAttrs: {
          doCheck = false;
          patches = (oldAttrs.patches or [ ]) ++ [
            (pkgs.writeText "border-rounding.patch" # cpp
              ''
                diff --git a/src/config/lua/bindings/LuaBindingsInternal.hpp b/src/config/lua/bindings/LuaBindingsInternal.hpp
                index 934c188c..6f861b38 100644
                --- a/src/config/lua/bindings/LuaBindingsInternal.hpp
                +++ b/src/config/lua/bindings/LuaBindingsInternal.hpp
                @@ -65,9 +65,9 @@ namespace Config::Lua::Bindings::Internal {
                         {"content", []() -> ILuaConfigValue* { return new CLuaConfigString(STRVAL_EMPTY); }, WE::WINDOW_RULE_EFFECT_CONTENT},
                         {"no_close_for", []() -> ILuaConfigValue* { return new CLuaConfigInt(0); }, WE::WINDOW_RULE_EFFECT_NOCLOSEFOR},
                         {"scrolling_width", []() -> ILuaConfigValue* { return new CLuaConfigFloat(0.F); }, WE::WINDOW_RULE_EFFECT_SCROLLING_WIDTH},
                -        {"rounding", []() -> ILuaConfigValue* { return new CLuaConfigInt(0, 0, 20); }, WE::WINDOW_RULE_EFFECT_ROUNDING},
                +        {"rounding", []() -> ILuaConfigValue* { return new CLuaConfigInt(0, 0, 60); }, WE::WINDOW_RULE_EFFECT_ROUNDING},
                         {"border_size", []() -> ILuaConfigValue* { return new CLuaConfigInt(0); }, WE::WINDOW_RULE_EFFECT_BORDER_SIZE},
                -        {"rounding_power", []() -> ILuaConfigValue* { return new CLuaConfigFloat(2.F, 1.F, 10.F); }, WE::WINDOW_RULE_EFFECT_ROUNDING_POWER},
                +        {"rounding_power", []() -> ILuaConfigValue* { return new CLuaConfigFloat(2.F, 1.F, 20.F); }, WE::WINDOW_RULE_EFFECT_ROUNDING_POWER},
                         {"scroll_mouse", []() -> ILuaConfigValue* { return new CLuaConfigFloat(1.F, 0.01F, 10.F); }, WE::WINDOW_RULE_EFFECT_SCROLL_MOUSE},
                         {"scroll_touchpad", []() -> ILuaConfigValue* { return new CLuaConfigFloat(1.F, 0.01F, 10.F); }, WE::WINDOW_RULE_EFFECT_SCROLL_TOUCHPAD},
                         {"animation", []() -> ILuaConfigValue* { return new CLuaConfigString(STRVAL_EMPTY); }, WE::WINDOW_RULE_EFFECT_ANIMATION},
                diff --git a/src/config/values/ConfigValues.cpp b/src/config/values/ConfigValues.cpp
                index 505ce700..53cc2b87 100644
                --- a/src/config/values/ConfigValues.cpp
                +++ b/src/config/values/ConfigValues.cpp
                @@ -198,9 +198,9 @@ std::vector<SP<IValue>> Values::getConfigValues() {
                          */

                         MS<Int>("decoration:rounding", "rounded corners' radius (in layout px)", 0,
                -                {.min = 0, .max = 20, .refresh = Supplementary::REFRESH_WINDOW_STATES | Supplementary::REFRESH_BLUR_FB}),
                +                {.min = 0, .max = 60, .refresh = Supplementary::REFRESH_WINDOW_STATES | Supplementary::REFRESH_BLUR_FB}),
                         MS<Float>("decoration:rounding_power", "rounding power of corners (2 is a circle)", 2,
                -                  {.min = 2, .max = 10, .refresh = Supplementary::REFRESH_WINDOW_STATES | Supplementary::REFRESH_BLUR_FB}),
                +                  {.min = 2, .max = 20, .refresh = Supplementary::REFRESH_WINDOW_STATES | Supplementary::REFRESH_BLUR_FB}),
                         MS<Float>("decoration:active_opacity", "opacity of active windows.", 1, {.min = 0, .max = 1, .refresh = Supplementary::REFRESH_WINDOW_STATES}),
                         MS<Float>("decoration:inactive_opacity", "opacity of inactive windows.", 1, {.min = 0, .max = 1, .refresh = Supplementary::REFRESH_WINDOW_STATES}),
                         MS<Float>("decoration:fullscreen_opacity", "opacity of fullscreen windows.", 1, {.min = 0, .max = 1, .refresh = Supplementary::REFRESH_WINDOW_STATES}),
                @@ -447,10 +447,10 @@ std::vector<SP<IValue>> Values::getConfigValues() {
                         MS<Bool>("group:groupbar:render_titles", "whether to render titles in the group bar decoration", true),
                         MS<Bool>("group:groupbar:scrolling", "whether scrolling in the groupbar changes group active window", true),
                         MS<Bool>("group:groupbar:middle_click_close", "whether middle clicking the groupbar closes the clicked window", true),
                -        MS<Int>("group:groupbar:rounding", "how much to round the groupbar", 1, {.min = 0, .max = 20}),
                -        MS<Float>("group:groupbar:rounding_power", "rounding power of groupbar corners (2 is a circle)", 2, {.min = 2, .max = 10}),
                -        MS<Int>("group:groupbar:gradient_rounding", "how much to round the groupbar gradient", 2, {.min = 0, .max = 20}),
                -        MS<Float>("group:groupbar:gradient_rounding_power", "rounding power of groupbar gradient corners (2 is a circle)", 2, {.min = 2, .max = 10}),
                +        MS<Int>("group:groupbar:rounding", "how much to round the groupbar", 1, {.min = 0, .max = 60}),
                +        MS<Float>("group:groupbar:rounding_power", "rounding power of groupbar corners (2 is a circle)", 2, {.min = 2, .max = 20}),
                +        MS<Int>("group:groupbar:gradient_rounding", "how much to round the groupbar gradient", 2, {.min = 0, .max = 60}),
                +        MS<Float>("group:groupbar:gradient_rounding_power", "rounding power of groupbar gradient corners (2 is a circle)", 2, {.min = 2, .max = 20}),
                         MS<Bool>("group:groupbar:round_only_edges", "if yes, will only round at the groupbar edges", true),
                         MS<Bool>("group:groupbar:gradient_round_only_edges", "if yes, will only round at the groupbar gradient edges", true),
                         MS<Color>("group:groupbar:text_color", "color for window titles in the groupbar", 0xffffffff),
                diff --git a/src/desktop/rule/windowRule/WindowRule.cpp b/src/desktop/rule/windowRule/WindowRule.cpp
                index 05353431..d024b924 100644
                --- a/src/desktop/rule/windowRule/WindowRule.cpp
                +++ b/src/desktop/rule/windowRule/WindowRule.cpp
                @@ -321,7 +321,7 @@ static std::expected<WindowRuleEffectValue, std::string> parseWindowRuleEffect(C
                             auto parsed = parseFloat(EFFECT_NAME, raw);
                             if (!parsed)
                                 return std::unexpected(parsed.error());
                -            return std::clamp(*parsed, 1.F, 10.F);
                +            return std::clamp(*parsed, 1.F, 20.F);
                         }
                         case WINDOW_RULE_EFFECT_SCROLL_MOUSE:
                         case WINDOW_RULE_EFFECT_SCROLL_TOUCHPAD: {
                diff --git a/src/desktop/view/Window.cpp b/src/desktop/view/Window.cpp
                index 072787c2..8a8a179c 100644
                --- a/src/desktop/view/Window.cpp
                +++ b/src/desktop/view/Window.cpp
                @@ -1068,7 +1068,7 @@ float CWindow::rounding() {
                 float CWindow::roundingPower() {
                     static auto PROUNDINGPOWER = CConfigValue<Config::FLOAT>("decoration:rounding_power");

                -    return m_ruleApplicator->roundingPower().valueOr(std::clamp(*PROUNDINGPOWER, 1.F, 10.F));
                +    return m_ruleApplicator->roundingPower().valueOr(std::clamp(*PROUNDINGPOWER, 1.F, 20.F));
                 }

                 void CWindow::updateWindowData() {
                --
                2.54.0

              ''
            )
          ];
        });
        xdg-desktop-portal-hyprland = inputs'.hyprland.packages.xdg-desktop-portal-hyprland.overrideAttrs {
          doCheck = false;
        };
      };
    };
}
