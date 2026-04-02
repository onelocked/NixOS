{ inputs, ... }:
{
  flake.modules.homeManager.quickshell =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    let
      quickshellDeps =
        with pkgs;
        [
          imagemagick
          wlsunset
          python3
          cava
          grim
          slurp
          wl-clipboard-rs
          tesseract
          zbar
        ]
        ++ (with pkgs.kdePackages; [
          qt6ct
          qtbase
          qtmultimedia
        ]);

      qmlImportPath = lib.makeSearchPath pkgs.kdePackages.qtbase.qtQmlPrefix quickshellDeps;

      quickshellWrapped = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.quickshell;
        runtimeInputs = quickshellDeps;
        env = {
          QT_QPA_PLATFORMTHEME = "gtk3";
          QML_IMPORT_PATH = qmlImportPath;
          QML2_IMPORT_PATH = qmlImportPath;
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
        EnvironmentFile = osConfig.sops.secrets.gemini.path;
      };
    };
}
