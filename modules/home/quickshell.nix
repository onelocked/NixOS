{ inputs, ... }:
{
  m.quickshell =
    {
      pkgs,
      lib,
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
        package = pkgs.quickshell;
        aliases = [ "qs" ];
        extraPackages = quickshellDeps;
        env = {
          QT_QPA_PLATFORMTHEME = "gtk3";
          QS_ICON_THEME = "Papirus-Dark";
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
