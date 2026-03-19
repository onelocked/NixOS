{ inputs, ... }:
{
  flake-file.inputs.quickshell = {
    url = "github:noctalia-dev/noctalia-qs/";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.homeManager.quickshell =
    {
      pkgs,
      lib,
      ...
    }:
    let
      quickshell-flake = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
      quickshell-deps =
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

      qmlImportPath = lib.makeSearchPath "lib/qt6/qml" quickshell-deps;

      quickshell = pkgs.symlinkJoin {
        name = "quickshell";
        paths = [ quickshell-flake ] ++ quickshell-deps;

        buildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/quickshell \
            --prefix PATH : ${lib.makeBinPath quickshell-deps} \
            --prefix QML_IMPORT_PATH : ${qmlImportPath}
        '';
        meta = {
          mainProgram = "quickshell";
        };
      };
    in
    {
      programs.quickshell = {
        enable = true;
        package = quickshell;
        systemd = {
          enable = true;
          target = "graphical-session.target";
        };
      };
      systemd.user.services.quickshell.Service = {
        Type = "dbus";
        BusName = "org.kde.StatusNotifierWatcher";
      };
    };
}
