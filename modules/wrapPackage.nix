{ lib, ... }:
let
  wrapPackage =
    pkgs:
    {
      package,
      binName ? package.meta.mainProgram or (lib.getName package),
      flags ? { },
      env ? { },
      runtimePkgs ? [ ],
      paths ? [ ],
      aliases ? [ ],
    }:
    pkgs.symlinkJoin {
      name = "${package.name}-wrapped";
      paths = [ package ] ++ paths;
      nativeBuildInputs = [ pkgs.makeWrapper ];
      meta = removeAttrs (package.meta or { }) [ "outputsToInstall" ] // {
        mainProgram = binName;
      };
      postBuild =
        let
          wrapperArgs = ''
            ${
              lib.concatStringsSep " \\\n  " (
                lib.mapAttrsToList (
                  n: v: "--add-flags ${lib.escapeShellArg n} --add-flags ${lib.escapeShellArg (toString v)}"
                ) flags
              )
            } \
            ${
              lib.concatStringsSep " \\\n  " (
                lib.mapAttrsToList (n: v: "--set ${lib.escapeShellArg n} ${lib.escapeShellArg (toString v)}") env
              )
            } \
            ${lib.optionalString (lib.length runtimePkgs > 0) "--prefix PATH : ${lib.makeBinPath runtimePkgs}"}
          '';
        in
        ''
          if [ ! -e $out/bin/${binName} ]; then
            makeWrapper ${lib.getExe' package (package.meta.mainProgram or (lib.getName package))} $out/bin/${binName} ${wrapperArgs}
          else
            wrapProgram $out/bin/${binName} ${wrapperArgs}
          fi

          ${lib.concatStringsSep "\n" (
            map (alias: "ln -sf $out/bin/${binName} $out/bin/${lib.escapeShellArg alias}") aliases
          )}
        '';
    };
in
{
  exo.core =
    { pkgs, ... }:
    {
      _module.args.wrapPackage = wrapPackage pkgs;
    };

  perSystem =
    { pkgs, ... }:
    {
      _module.args.wrapPackage = wrapPackage pkgs;
    };
}
