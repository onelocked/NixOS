{ inputs, ... }:
{
  ff = {
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    oneshill = {
      url = "git+https://gitea.onelock.org/onelock/oneshill.git?ref=retroid";
      flake = false;
    };
  };
  exo.skeleton =
    {
      lib,
      pkgs,
      birdee,
      self',
      config,
      constants,
      ...
    }:
    let
      cfg = config.forte.quickshell;
      runtimePkgs =
        with pkgs.kdePackages;
        [ qtmultimedia ]
        ++ (with pkgs; [
          ddcutil
          imagemagick
          cava
          python3
          awww
        ]);

      qmlImportPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtQmlPrefix runtimePkgs; # lib/qt-6/qml

      qtPluginPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtPluginPrefix runtimePkgs; # lib/qt-6/plugins
    in
    {
      config = lib.mkIf (cfg.enable) {
        hj = {
          packages = [
            cfg.package
            cfg.oneshill
          ];
          systemd.services.quickshell = {
            description = "quickshell";
            after = [ "graphical-session.target" ];
            wantedBy = [ "graphical-session.target" ];
            path = with pkgs; [
              bash
              coreutils
              gnugrep
              gnused
              gawk
              procps
            ];
            serviceConfig = {
              Type = "dbus";
              BusName = "org.kde.StatusNotifierWatcher";
              ExecStart = "${cfg.oneshill}/bin/oneshill";
              Restart = "on-failure";

              MemoryHigh = "512M";
              MemoryMax = "768M";
            };
          };
          systemd.services.awww = {
            description = "awww wallpaper daemon";
            wantedBy = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            after = [ "graphical-session.target" ];
            serviceConfig = {
              Type = "simple";
              ExecStart = "${lib.getExe' pkgs.awww "awww-daemon"}";
              Restart = "on-failure";
              RestartSec = 1;
              TimeoutStopSec = 10;
            };
          };
        };
        forte.hyprland.lua.keybinds = # lua
          ''
            -- brightness
            hl.bind("ALT + SHIFT + equal", hl.dsp.exec_raw("oneshill ipc call brightness increase"),
              { locked = true, repeating = false })

            hl.bind("ALT + SHIFT + minus", hl.dsp.exec_raw("oneshill ipc call brightness decrease"),
              { locked = true, repeating = false })

            -- wallpaper panel toggle
            hl.bind("ALT + SHIFT + W", hl.dsp.exec_raw("oneshill ipc call WallpaperPanel toggle"),
              { locked = true, repeating = false })

            -- quickshell + hyprland overview
            local original_gaps = { top = 60, bottom = 30, left = 30, right = 30 }
            local original_fit_method = nil

            hl.define_submap("hyprview", function()
              hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
              hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
              hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
              hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

              hl.bind("SUPER + up", hl.dsp.focus({ workspace = "e-1" }))
              hl.bind("SUPER + down", hl.dsp.focus({ workspace = "e+1" }))

              hl.bind("SUPER + G", function()
                hl.dispatch(hl.dsp.exec_raw("oneshill ipc call overview toggle"))
                hl.config({
                  general   = { gaps_out = original_gaps },
                  scrolling = { focus_fit_method = original_fit_method },
                })
                hl.dispatch(hl.dsp.submap("reset"))
              end, { repeating = false })
            end)

            hl.bind("SUPER + G", function()
              -- Save current value before overriding
              original_fit_method = hl.get_config("scrolling.focus_fit_method")

              hl.dispatch(hl.dsp.exec_raw("oneshill ipc call overview toggle"))
              hl.config({
                general   = { gaps_out = { top = 180, bottom = 180, left = 260, right = 260 } },
                scrolling = { focus_fit_method = 0 },
              })
              hl.dispatch(hl.dsp.submap("hyprview"))
            end, { repeating = false })

          '';
        systemd.tmpfiles.rules = [
          "L+ ${config.hj.xdg.config.directory}/quickshell - onelock users - ${config.hj.directory}/Development/quickshell/oneshill"
        ];
        systemd.tmpfiles.settings.preservation = {
          "${config.hj.directory}/.netrc".z = lib.mkForce {
            user = constants.username;
            group = "users";
            mode = "0600";
          };
        };
        forte.persist.home = {
          files = [ ".netrc" ];
          directories = [
            ".config/oneshill"
            ".cache/oneshill"
          ];
        };
      };
      options = {
        forte.quickshell = {
          enable = lib.mkEnableOption "quickshell" // {
            default = true;
          };
          package = lib.mkOption {
            type = lib.types.package;
            default = birdee.lib.wrapPackage {
              inherit pkgs;
              inherit runtimePkgs;
              package = self'.packages.quickshell;
              aliases = [ "qs" ];
              env = {
                QT_QPA_PLATFORMTHEME = "gtk3";
                QS_ICON_THEME = config.forte.gtk.icons.name;
                QS_DROP_EXPENSIVE_FONTS = "1";
                QML_IMPORT_PATH = qmlImportPath;
                QML2_IMPORT_PATH = qmlImportPath;
                QT_PLUGIN_PATH = qtPluginPath;
                FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.lucide ]; };
              };
            };
          };
          oneshill = lib.mkOption {
            type = lib.types.package;
            default = pkgs.symlinkJoin {
              name = "oneshill";
              meta.mainProgram = "oneshill";
              paths = [ cfg.package ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                makeWrapper ${pkgs.lib.getExe cfg.package} $out/bin/oneshill \
                  --add-flags '-p ${inputs.oneshill}'
              '';
            };
          };
        };
      };
    };
  perSystem =
    { inputs', ... }:
    {
      packages.quickshell =
        (inputs'.quickshell.packages.default.override {
          withWayland = true;
          withPipewire = true;
          withQtSvg = true;
          withJemalloc = true;

          withNetworkManager = false;
          withPolkit = false;
          withHyprland = false;
          withPam = false;
          withX11 = false;
          withI3 = false;
        }).overrideAttrs
          { doCheck = false; };
    };
}
