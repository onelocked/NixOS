{
  ff = {
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qml-niri = {
      url = "github:imiric/qml-niri/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        quickshell.follows = "quickshell";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };
  m.quickshell.forte.quickshell.enable = true;
  m.default =
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
      quickshellDeps =
        with pkgs.kdePackages;
        [ qtmultimedia ]
        ++ (with pkgs; [
          ddcutil
          imagemagick
          cava
          python3
          awww
        ]);

      qmlImportPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtQmlPrefix quickshellDeps; # lib/qt-6/qml

      qtPluginPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtPluginPrefix quickshellDeps; # lib/qt-6/plugins
    in
    {
      options.forte.quickshell = {
        enable = lib.mkEnableOption "quickshell";
        package = lib.mkOption {
          default = birdee.lib.wrapPackage {
            inherit pkgs;
            package = self'.packages.quickshell;
            aliases = [ "qs" ];
            extraPackages = quickshellDeps;
            env = {
              QT_QPA_PLATFORMTHEME = "gtk3";
              QS_ICON_THEME = config.custom.gtk.iconTheme.name;
              QS_DROP_EXPENSIVE_FONTS = "1";
              QML_IMPORT_PATH = qmlImportPath;
              QML2_IMPORT_PATH = qmlImportPath;
              QT_PLUGIN_PATH = qtPluginPath;
              FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.lucide ]; };
            };
          };
        };
      };
      config = lib.mkIf (cfg.enable) {
        hj = {
          packages = [ cfg.package ];
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
              ExecStart = "${cfg.package}/bin/qs --no-duplicate";
              Restart = "on-failure";
            };
          };
        };

        forte.niri.settings.binds = {
          "Shift+Alt+W" = _: {
            props = {
              repeat = false;
            };
            content = {
              spawn = [
                "qs"
                "ipc"
                "call"
                "wallpaper"
                "toggle"
              ];
            };
          };

          # Hardware Controls via Quickshell
          "ALT+Shift+Equal" = _: {
            props = {
              repeat = false;
            };
            content = {
              spawn = [
                "qs"
                "ipc"
                "call"
                "brightness"
                "increase"
              ];
            };
          };
          "ALT+Shift+Minus" = _: {
            props = {
              repeat = false;
            };
            content = {
              spawn = [
                "qs"
                "ipc"
                "call"
                "brightness"
                "decrease"
              ];
            };
          };
        };
      };
    };
  perSystem =
    { inputs', ... }:
    {
      packages.quickshell =
        (inputs'.qml-niri.packages.quickshell.override {
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
