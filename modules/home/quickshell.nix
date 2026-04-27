{ inputs, ... }:
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
  m.quickshell =
    {
      pkgs,
      lib,
      config,
      self',
      ...
    }:
    let
      quickshellDeps =
        with pkgs.kdePackages;
        [ qtmultimedia ]
        ++ (with pkgs; [
          imagemagick
          cava
          python3
          awww
        ]);

      qmlImportPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtQmlPrefix quickshellDeps; # lib/qt-6/qml

      qtPluginPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtPluginPrefix quickshellDeps; # lib/qt-6/plugins

      quickshellWrapped = inputs.wrappers.lib.wrapPackage {
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
        };
      };
    in
    {
      fonts.packages = [ pkgs.lucide ];
      hj = {
        packages = [ quickshellWrapped ];

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
            ExecStart = "${quickshellWrapped}/bin/qs --no-duplicate";
            Restart = "on-failure";
          };
        };
      };
    };
}
