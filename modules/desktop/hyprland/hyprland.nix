{
  tack.inputs = {
    hyprland = {
      url = "gh:hyprwm/Hyprland";
    };
    fetch.hypr-plugs = "gh:hyprwm/hyprland-plugins";
    fetch.scroll-overview = "gh:yayuuu/hyprland-scroll-overview/new-release";
  };
  exo.mods.desktop = {
    forte.hyprland = {
      enable = true;
      withUWSM = true;
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
      pkgs,
      self',
      constants,
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
            security.pam.services.login.enableGnomeKeyring = true;
            services.getty.autologinUser = constants.username;
            programs.bash.loginShellInit = # bash
              ''
                # Auto start wayland session on tty1 if no session exists
                if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && "$(tty)" == '/dev/tty1' ]]; then
                  ${
                    if cfg.withUWSM then
                      "exec uwsm start hyprland-uwsm.desktop"
                    else
                      "exec ${lib.getExe' cfg.package "start-hyprland"}"
                  }
                fi
              '';
          }
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
        scrolloverview = self'.packages.hyprland.stdenv.mkDerivation (finalAttrs: {
          pname = "scrolloverview";
          version = "1.0";
          src = inputs.scroll-overview;

          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [
            pkgs.lua5_4
            self'.packages.hyprland
          ]
          ++ self'.packages.hyprland.buildInputs;

          enableParallelBuilding = true;
          dontUseCmakeConfigure = true;

          buildPhase = ''
            runHook preBuild
            export SCROLLOVERVIEW_BUILD_VERSION="1.0"
            make all
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p "$out/lib"
            mv scrolloverview.so "$out/lib/libscrolloverview.so"
            runHook postInstall
          '';

          meta = {
            homepage = "https://github.com/yayuuu/hyprland-scroll-overview";
            description = "scroll overview";
            platforms = self'.packages.hyprland.meta.platforms or [ ];
          };
        });
      };
      packages = {
        hyprland = packages'.hyprland.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
        xdg-desktop-portal-hyprland =
          (packages'.hyprland.xdg-desktop-portal-hyprland.override {
            hyprland = self'.packages.hyprland;
          }).overrideAttrs
            {
              doCheck = false;
            };
      };
      remotePackages = {
        hyprland-bundle = pkgs.symlinkJoin {
          name = "hyprland-bundle";
          paths = [
            self'.packages.hyprland
            self'.packages.xdg-desktop-portal-hyprland
            self'.legacyPackages.scrolloverview
          ];
        };
      };
    };
}
