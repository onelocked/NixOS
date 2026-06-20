{ inputs, ... }:
{
  ff = {
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    oneshill = {
      url = "git+ssh://git@gitea.onelock.org/onelock/oneshill.git?ref=retroid";
      flake = false;
    };
  };
  exo.mods.desktop = {
    forte.quickshell.enable = true;
  };
  exo.skeleton =
    {
      lib,
      pkgs,
      birdee,
      self',
      config,
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
        systemd.tmpfiles.rules = [
          "L+ ${config.hj.xdg.config.directory}/quickshell - onelock users - ${config.hj.directory}/Development/quickshell/oneshill"
        ];
        forte.persist.home.directories = [
          ".config/oneshill"
          ".cache/oneshill"
        ];
      };
      options = {
        forte.quickshell = {
          enable = lib.mkEnableOption "quickshell";
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
