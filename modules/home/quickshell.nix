{ inputs, ... }:
{
  flake.modules.homeManager.quickshell =
    {
      pkgs,
      osConfig,
      ...
    }:
    let
      quickshellWrapped = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.quickshell;
        runtimeInputs =
          with pkgs;
          [
            imagemagick
            wlsunset
            python3
            cava
          ]
          ++ (with pkgs.kdePackages; [
            qt6ct
            qtbase
            qtmultimedia
          ]);
        env = {
          QT_QPA_PLATFORMTHEME = "gtk3";
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
