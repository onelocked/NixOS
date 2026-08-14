{
  tack.inputs = {
    hyprland = "gh:hyprwm/Hyprland";
    fetch.hypr-plugs = "gh:hyprwm/hyprland-plugins";
  };
  exo.mods.desktop = {
    forte.hyprland = {
      enable = true;
      withUWSM = true;
      withGreetd = true;
      withTermFileChooser = true;
      withHyprpolkit = false;
      withHyprshutdown = true;
      withHypridle = false;
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
      cfg = config.forte.hyprland;
      autoLoadFiles = lib.filterAttrs (_: file: file.autoLoad) cfg.lua;
    in
    {
      config =
        lib.mkIf cfg.enable
        <| lib.mkMerge [
          {
            hj.packages = [ cfg.package ];

            forte.hyprland.plugins = [ self'.legacyPackages.borders-plus-plus ];

            forte.persist.home.directories = [ ".config/hypr" ];
            forte.hyprland.lua.autostart =
              lib.optionalString (cfg.autostart != [ ] || cfg.plugins != [ ]) # lua
                ''
                  hl.on("hyprland.start", function()
                  ${lib.concatStringsSep "\n" (map (cmd: "  hl.dispatch(hl.dsp.exec_raw(\"${cmd}\"))") cfg.autostart)}
                  ${
                    cfg.plugins
                    |> lib.concatMapStrings (entry: ''
                      hl.dispatch(hl.dsp.exec_raw("${config.forte.hyprland.package}/bin/hyprctl plugin load ${
                        if lib.types.package.check entry then "${entry}/lib/lib${entry.pname}.so" else entry
                      }"))
                    '')
                  }
                  end)
                '';
            hj.xdg.config.files = lib.mkMerge [
              (lib.mkIf (autoLoadFiles != { }) {
                "hypr/hyprland.lua".text =
                  let
                    priority = [ "settings" ];
                    rank = name: lib.lists.findFirstIndex (x: x == name) (builtins.length priority) priority;
                  in
                  builtins.attrNames autoLoadFiles
                  |> builtins.sort (
                    a: b:
                    let
                      ra = rank a;
                      rb = rank b;
                    in
                    if ra != rb then ra < rb else a < b
                  )
                  |> map (name: ''require("${lib.removeSuffix ".lua" name}")'')
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
                  |> builtins.concatStringsSep "\n";
              })
              (
                cfg.lua
                |> lib.mapAttrs' (
                  name: file:
                  lib.nameValuePair "hypr/${
                    lib.replaceStrings [ "." ] [ "/" ] (lib.removeSuffix ".lua" name) + ".lua"
                  }" (if lib.isPath file.content then { source = file.content; } else { text = file.content; })
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
                "hypr/xdph.conf".text = # kdl
                  ''
                    screencopy {
                        max_fps = 60
                        allow_token_by_default = true
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
          (lib.mkIf cfg.withHyprshutdown {
            environment.shellAliases = {
              shutdown = ''${lib.getExe pkgs.hyprshutdown} -t "Shutting down..." --post-cmd "shutdown -P 0"'';
              reboot = ''${lib.getExe pkgs.hyprshutdown} -t "Restarting..." --post-cmd "reboot"'';
            };
          })
          (lib.mkIf (hardware == "mini-pc") {
            environment.sessionVariables = {
              AQ_NO_MODIFIERS = 1;
            };
          })
          (lib.mkIf (cfg.withHypridle) {
            hj.packages = [ pkgs.hypridle ];
            hj.systemd.services.hypridle = {
              description = "Hypridle autostart";
              after = [ "graphical-session.target" ];
              wantedBy = [ "graphical-session.target" ];
              serviceConfig = {
                Type = "simple";
                ExecStart = "${lib.getExe pkgs.hypridle}";
                Restart = "on-failure";
                RestartSec = 1;
                TimeoutStopSec = 10;
              };
            };
            hj.xdg.config.files = {
              "hypr/hypridle.conf".text = # bash
                ''
                  general {
                      ignore_dbus_inhibit = false
                      ignore_systemd_inhibit = false
                      #lock the computer before sleeping
                      before_sleep_cmd = ${config.forte.quickshell.package}/bin/tuishell ipc call lock lock
                  }
                  listener {
                      timeout = 500
                      on-timeout = ${config.forte.quickshell.package}/bin/tuishell ipc call lock lock
                  }
                  listener {
                      timeout = 600 # 600 seconds = 10 minutes
                      on-timeout = ${config.forte.hyprland.package}/bin/hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'  # Turn off the screen
                      on-resume = ${config.forte.hyprland.package}/bin/hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })'  # Turn it on when waking up
                  }
                '';
            };
          })
        ];
      options.forte.hyprland = {
        enable = lib.mkEnableOption ''
          Hyprland, the dynamic tiling Wayland compositor that doesn't sacrifice on its looks.
          You can manually launch Hyprland by executing {command}`start-hyprland` on a TTY.
          A configuration file will be generated in {file}`~/.config/hypr/hyprland.conf`.
          See <https://wiki.hyprland.org> for more information'';

        autostart = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          description = "Applications to start on hyprland startup";
        };

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
        withHyprshutdown = lib.mkEnableOption null // {
          description = ''
            Whether to enable hyprshutdown
          '';
        };

        withHypridle = lib.mkEnableOption null // {
          description = ''
            Whether to enable hypridle
          '';
        };
      };
    };
  perSystem =
    {
      packages',
      pkgs,
      inputs,
      self',
      ...
    }:
    {
      legacyPackages = {
        borders-plus-plus = pkgs.hyprlandPlugins.mkHyprlandPlugin {
          pluginName = "borders-plus-plus";
          version = "0.1";
          src = "${inputs.hypr-plugs}/borders-plus-plus";
          hyprland = self'.packages.hyprland;

          inherit (self'.packages.hyprland) nativeBuildInputs;
          meta = {
            homepage = "https://github.com/hyprwm/hyprland-plugins/tree/main/borders-plus-plus";
            description = "Hyprland borders-plus-plus plugin";
          };
        };
      };
      packages = {
        hyprland = packages'.hyprland.overrideAttrs (oldAttrs: {
          doCheck = false;
          patches = (oldAttrs.patches or [ ]) ++ [
            (pkgs.writeText "fix-layer-shell-kb-grab" # cpp
              ''
                diff --git a/src/desktop/state/FocusState.cpp b/src/desktop/state/FocusState.cpp
                index c65a4550dca..172da082ecc 100644
                --- a/src/desktop/state/FocusState.cpp
                +++ b/src/desktop/state/FocusState.cpp
                @@ -97,7 +97,7 @@ void CFocusState::rawWindowFocus(PHLWINDOW pWindow, eFocusReason reason, SP<CWLS
                     static auto PFOLLOWMOUSE        = CConfigValue<Config::INTEGER>("input:follow_mouse");
                     static auto PSPECIALFALLTHROUGH = CConfigValue<Config::INTEGER>("input:special_fallthrough");

                -    if (pWindow == m_focusWindow && surface == m_focusSurface)
                +    if (pWindow == m_focusWindow && surface == m_focusSurface && m_focusSurface)
                         return;

                     if (!pWindow || !pWindow->priorityFocus()) {
                @@ -194,7 +194,6 @@ void CFocusState::rawWindowFocus(PHLWINDOW pWindow, eFocusReason reason, SP<CWLS
                     }

                     const auto PWINDOWSURFACE = surface ? surface : pWindow->wlSurface()->resource();
                -
                     rawSurfaceFocus(PWINDOWSURFACE, pWindow);

                     g_pXWaylandManager->activateWindow(pWindow, true); // sets the m_pLastWindow
              ''
            )
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
        xdg-desktop-portal-hyprland = packages'.hyprland.xdg-desktop-portal-hyprland.overrideAttrs {
          doCheck = false;
        };
      };
    };
}
