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
              runShell
              ;
          in
          pkgs.symlinkJoin {
            name = "${package.name}-onewrap";
            paths = [
              package
            ]
            ++ [
              (
                let
                  mkList =
                    prefix: attrs:
                    lib.attrNames attrs
                    |> map (
                      name:
                      let
                        value = attrs.${name};
                        target = if prefix == "" then name else "${prefix}/${name}";
                      in
                      if lib.isAttrs value && !(lib.isDerivation value) then
                        mkList target value
                      else
                        {
                          name = target;
                          path =
                            if (lib.isString value) && !(lib.hasPrefix builtins.storeDir value) then
                              (value |> pkgs.writeText "${lib.baseNameOf name}-text")
                            else
                              value;
                        }
                    );
                in
                files |> mkList "" |> lib.flatten |> pkgs.linkFarm "${package.name}"
              )
            ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            meta = removeAttrs (package.meta or { }) [ "outputsToInstall" ] // {
              mainProgram = binName;
            };
            postBuild =
              let
                wrapperArgs =
                  lib.escapeShellArgs
                  <| (
                    (
                      args
                      |> lib.concatMap (v: [
                        "--add-flags"
                        v
                      ])
                    )
                    ++ (
                      runShell
                      |> lib.concatMap (v: [
                        "--run"
                        v
                      ])
                    )
                    ++ (
                      lib.attrNames env
                      |> map (
                        n:
                        let
                          v = env.${n};
                        in
                        [
                          "--set"
                          n
                          (v |> toString)
                        ]
                      )
                      |> lib.concatLists
                    )
                    ++ (lib.optionals (extraPkgs != [ ]) [
                      "--prefix"
                      "PATH"
                      ":"
                      (extraPkgs |> lib.makeBinPath)
                    ])
                  );
                bin = binName |> lib.escapeShellArg;
              in
              #bash
              ''
                if [ ! -e "$out/bin/${bin}" ]; then
                  makeWrapper ${
                    lib.getExe' package (package.meta.mainProgram or (lib.getName package))
                  } "$out/bin/${bin}" ${wrapperArgs}
                else
                  wrapProgram "$out/bin/${bin}" ${wrapperArgs}
                fi
                ${
                  aliases
                  |> lib.concatMapStringsSep "\n" (
                    alias: "ln -sf $out/bin/${bin} $out/bin/${lib.escapeShellArg alias}"
                  )
                }
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
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Files to link into the wrapper. Can be nested.";
        };

        aliases = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        runShell = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Commands to run before executing the main program.";
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
    out = "${placeholder "out"}/";
    out' = placeholder "out";
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
