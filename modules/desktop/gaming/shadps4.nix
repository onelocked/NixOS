{
  exo.mods.desktop = { pkgs, ... }: {
    hj.packages = [ pkgs.shadps4-qtlauncher ];
    forte.persist.home.directories = [ ".local/share/shadPS4" ];
  };
  perSystem =
    { pkgs, ... }:
    {
      packages.pkg-install = pkgs.callPackage (
        {
          lib,
          stdenv,
          fetchFromGitHub,
          cmake,
          qt6,
          cryptopp,
        }:

        stdenv.mkDerivation (finalAttrs: {
          pname = "pkg-install";
          version = "0-unstable-2025-11-11";
          __structuredAttrs = true;
          strictDeps = true;

          src = fetchFromGitHub {
            owner = "Muggle345";
            repo = "PKGInstall";
            rev = "902d14c1a3c277a586e4c0c4db0774d06bda3501";
            hash = "sha256-iY8+3U271eUKAl9xgw5FZQKG6l49GkjUYJQT3fmW9os=";
            fetchSubmodules = true;
          };

          doCheck = false;

          nativeBuildInputs = [
            cmake
            qt6.wrapQtAppsHook
          ];

          buildInputs = [
            qt6.qtbase
            qt6.qttools
            qt6.qtdeclarative
            qt6.qtmultimedia
            qt6.wrapQtAppsHook
            cryptopp
          ];

          postPatch = "cp -r dist/* . ";

          postInstall = "install -Dm755 PKGInstall $out/bin/PKGInstall ";

          meta = {
            description = "pkg install for shadps4";
            homepage = "https://github.com/Muggle345/PKGInstall";
            mainProgram = "pkg-install";
            platforms = lib.platforms.all;
          };
        })
      ) { };
    };
}
