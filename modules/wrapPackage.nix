{ lib, ... }:
let
  wrapPackage =
    pkgs:
    {
      package,
      binName ? package.meta.mainProgram or (lib.getName package),
      args ? [ ],
      env ? { },
      extraPkgs ? [ ],
      files ? { },
      aliases ? [ ],
    }:
    pkgs.symlinkJoin {
      name = "${package.name}-wrapped";
      paths = [
        (
          files
          |> lib.mapAttrsToList (
            name: value:
            let
              path =
                if (value |> lib.isString) then
                  if (lib.hasPrefix builtins.storeDir value && !(lib.hasInfix "\n" value)) then
                    value
                  else
                    (value |> pkgs.writeText "${lib.baseNameOf name}-text")
                else
                  value;
            in
            {
              inherit name path;
            }
          )
          |> pkgs.linkFarm "${package.name}"
        )
        package
      ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      meta = removeAttrs (package.meta or { }) [ "outputsToInstall" ] // {
        mainProgram = binName;
      };
      postBuild =
        let
          env' =
            env
            |> lib.mapAttrsToList (n: v: "--set ${lib.escapeShellArg n} ${lib.escapeShellArg (toString v)}")
            |> lib.concatStringsSep " \\\n  ";

          args' = args |> map (v: "--add-flags ${lib.escapeShellArg v}") |> lib.concatStringsSep " \\\n  ";

          extraPkgs' = lib.optionalString (extraPkgs != [ ]) " --prefix PATH : ${lib.makeBinPath extraPkgs}";

          aliases' =
            aliases
            |> map (alias: "ln -sf $out/bin/${binName} $out/bin/${lib.escapeShellArg alias}")
            |> lib.concatStringsSep "\n";

          binName' = lib.escapeShellArg binName;

          wrapperArgs = "${args'} ${env'}${extraPkgs'}";
        in
        #bash
        ''
          if [ ! -e $out/bin/${binName'} ]; then
            makeWrapper ${
              lib.getExe' package (package.meta.mainProgram or (lib.getName package))
            } $out/bin/${binName'} ${wrapperArgs}
          else
            wrapProgram $out/bin/${binName'} ${wrapperArgs}
          fi

          ${lib.optionalString (aliases != [ ]) aliases'}
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
