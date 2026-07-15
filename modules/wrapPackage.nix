{ lib, ... }:
let
  wrapperModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = {
        wrapper =
          let
            inherit (config)
              package
              binName
              args
              env
              extraPkgs
              files
              aliases
              ;
          in
          pkgs.symlinkJoin {
            name = "${package.name}-onewrap";
            paths = [
              package
            ]
            ++ [
              (
                files
                |> lib.mapAttrsToList (
                  name: value:
                  let
                    path =
                      if (value |> lib.isString) && !(lib.hasPrefix builtins.storeDir value) then
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
      };
      options = {
        package = lib.mkOption {
          type = lib.types.package;
          description = "The package to wrap.";
        };

        binName = lib.mkOption {
          type = lib.types.str;
          default = config.package.meta.mainProgram or (lib.getName config.package);
          description = "Name of the wrapped binary at $out/bin/<binName>.";
        };

        args = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        env = lib.mkOption {
          type =
            with lib.types;
            attrsOf (oneOf [
              str
              number
              bool
              path
            ]);
          default = { };
        };

        extraPkgs = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
        };

        files = lib.mkOption {
          type = lib.types.attrsOf (lib.types.either lib.types.str lib.types.path);
          default = { };
        };

        aliases = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        wrapper = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          description = "The built, wrapped derivation.";
        };
      };
    };

  wrap =
    pkgs: spec:
    (lib.evalModules {
      modules = [
        wrapperModule
        spec
      ];
      specialArgs = { inherit pkgs; };
    }).config.wrapper;

  wrapFunctor = pkgs: {
    inherit pkgs;
    __functor = self: spec: wrap pkgs spec;
    out = placeholder "out";
    toml = (pkgs.formats.toml { }).generate "config.toml";
    json = (pkgs.formats.json { }).generate "config.json";
    yaml = (pkgs.formats.yaml { }).generate "config.yaml";
    ini = (pkgs.formats.ini { }).generate "config.ini";
  };
in
{
  exo.core =
    { pkgs, ... }:
    {
      _module.args.wrapPackage = wrapFunctor pkgs;
    };
  perSystem =
    { pkgs, ... }:
    {
      _module.args.wrapPackage = wrapFunctor pkgs;
    };
}
