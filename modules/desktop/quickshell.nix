{ inputs, ... }:
{
  tack.inputs = {
    tuishell = {
      url = "git+https://gitea.onelock.org/onelock/tuishell";
      fetch = true;
    };
    quickshell = "gh:quickshell-mirror/quickshell/ead3b00afdf603bb6d4c30fc9c9f582d8f712168";
  };
  exo.mods.desktop =
    {
      lib,
      pkgs,
      wrapPackage,
      self',
      config,
      constants,
      ...
    }:
    let
      cfg = config.forte.quickshell;
    in
    {
      config = lib.mkIf (cfg.enable) {
        hj = {
          packages = [ cfg.package ];
          systemd.services.quickshell = {
            enableDefaultPath = false;
            description = "quickshell";
            after = [ "graphical-session.target" ];
            wantedBy = [ "graphical-session.target" ];
            serviceConfig = {
              Type = "dbus";
              BusName = "org.kde.StatusNotifierWatcher";
              ExecStart = "${cfg.package}/bin/tuishell";
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
        forte.hyprland.lua.settings = # lua
          ''
            hl.layer_rule({
              name = "tuishell",
              match = {
                namespace = "^tuishell-.*",
              },
              no_anim = true,
              ignore_alpha = 0.5,
              blur = true,
              blur_popups = true,
              xray = true,
            })
          '';
        forte.hyprland.lua.keybinds = # lua
          ''
            -- brightness
            hl.bind("ALT + SHIFT + equal", hl.dsp.exec_raw("tuishell ipc call brightness increase"),
              { locked = true, repeating = false })

            hl.bind("ALT + SHIFT + minus", hl.dsp.exec_raw("tuishell ipc call brightness decrease"),
              { locked = true, repeating = false })

            hl.bind("SUPER + G", hl.dsp.exec_raw("tuishell ipc call desktop toggleWidgets"),
              { locked = true, repeating = false })

            hl.bind("SUPER + SPACE", hl.dsp.exec_raw("tuishell ipc call launcher toggle"),
              { locked = true, repeating = false })
            hl.bind("SUPER + ALT + L", hl.dsp.exec_raw("tuishell ipc call lock lock"),
              { locked = true, repeating = false })
          '';
        systemd.tmpfiles.settings.preservation = {
          "${config.hj.directory}/.netrc".z = lib.mkForce {
            user = constants.username;
            group = "users";
            mode = "0600";
          };
        };
        forte.persist.home = {
          files = [ ".netrc" ];
          directories = [ ".cache/tuishell" ];
        };
      };
      options = {
        forte.quickshell = {
          enable = lib.mkEnableOption "quickshell" // {
            default = true;
          };
          package = lib.mkOption {
            type = lib.types.package;
            default = wrapPackage {
              binName = "tuishell";
              args = [ "-p ${inputs.tuishell}" ];
              package =
                let
                  extraPkgs =
                    with pkgs.kdePackages;
                    [ qtmultimedia ]
                    ++ (with pkgs; [
                      ddcutil
                      imagemagick
                      cava
                      python3
                      awww
                      config.forte.mpv.mpv-wlpaste
                    ]);

                  qmlImportPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtQmlPrefix extraPkgs; # lib/qt-6/qml
                  qtPluginPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtPluginPrefix extraPkgs; # lib/qt-6/plugins
                in
                wrapPackage {
                  inherit extraPkgs;
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
          };
        };
      };
    };
  perSystem =
    { packages', ... }:
    {
      packages.quickshell =
        (packages'.quickshell.override {
          withWayland = true;
          withPipewire = true;
          withQtSvg = true;
          withJemalloc = true;
          withHyprland = true;
          withNetworkManager = true;
          withPolkit = true;
          withPam = true;

          withX11 = false;
          withI3 = false;
        }).overrideAttrs
          { doCheck = false; };
    };
}
