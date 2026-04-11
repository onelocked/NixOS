{ inputs, ... }:
{
  flake.modules.homeManager.quickshell =
    {
      pkgs,
      osConfig,
      config,
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
        ]);

      qmlImportPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtQmlPrefix quickshellDeps; # lib/qt-6/qml

      qtPluginPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtPluginPrefix quickshellDeps; # lib/qt-6/plugins

      quickshellWrapped = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.quickshell;
        aliases = [ "qs" ];
        runtimeInputs = quickshellDeps;
        env = {
          QT_QPA_PLATFORMTHEME = "gtk3";
          QS_ICON_THEME = "Papirus-Dark";
          QS_DROP_EXPENSIVE_FONTS = 1;
          QML_IMPORT_PATH = qmlImportPath;
          QML2_IMPORT_PATH = qmlImportPath;
          QT_PLUGIN_PATH = qtPluginPath;
          XDG_DATA_DIRS = "${lib.makeSearchPath "share" [ pkgs.lucide ]}\${XDG_DATA_DIRS:+:\$XDG_DATA_DIRS}";
        };
      };
    in
    {
      programs.quickshell = {
        enable = true;
        package = quickshellWrapped;
        systemd = {
          enable = true;
          target = "graphical-session.target";
        };
      };
      systemd.user.services.quickshell.Service = {
        Type = "dbus";
        BusName = "org.kde.StatusNotifierWatcher";
        ExecStart = lib.mkForce "${config.programs.quickshell.package}/bin/quickshell --no-duplicate";
        EnvironmentFile = osConfig.sops.secrets.gemini.path;
      };
    };
}
