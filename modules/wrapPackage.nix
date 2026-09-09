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
        makeWrapperArgs = lib.mkMerge [
          (lib.mkIf (config.args != [ ]) (
            config.args
            |> lib.concatMap (value: [
              "--add-flags"
              value
            ])
          ))
          (lib.mkIf (config.runShell != [ ]) (
            config.runShell
            |> lib.concatMap (value: [
              "--run"
              value
            ])
          ))
          (lib.mkIf (config.env != { }) (
            lib.attrNames config.env
            |> map (name: [
              "--set"
              name
              (config.env.${name} |> toString)
            ])
            |> lib.concatLists
          ))
          (lib.mkIf (config.extraPkgs != [ ]) [
            "--prefix"
            "PATH"
            ":"
            (config.extraPkgs |> lib.makeBinPath)
          ])
        ];
        wrapper =
          let
            inherit (config)
              package
              paths
              binName
              files
              aliases
              makeWrapperArgs
              ;
            flattenFiles =
              prefix: attrs:
              lib.concatLists (
                lib.mapAttrsToList (
                  name: value:
                  let
                    target = if prefix == "" then name else "${prefix}/${name}";
                  in
                  if lib.isAttrs value && !lib.isDerivation value then
                    flattenFiles target value
                  else
                    [
                      {
                        name = target;
                        inherit value;
                      }
                    ]
                ) attrs
              );
            inherit
              (
                flattenFiles "" files
                |> builtins.partition (file: lib.isString file.value && !lib.hasPrefix builtins.storeDir file.value)
              )
              right
              wrong
              ;
            textFiles = right |> lib.imap0 (index: file: file // { key = "f${toString index}"; });
            linkFiles = wrong;
          in
          pkgs.runCommandLocal "${package.name}-onewrap"
            (
              {
                nativeBuildInputs = with pkgs; [
                  makeWrapper
                  lndir
                ];
                meta = removeAttrs (package.meta or { }) [ "outputsToInstall" ] // {
                  mainProgram = binName;
                };
                passAsFile = textFiles |> map (file: file.key);
              }
              // (
                textFiles
                |> map (file: {
                  name = file.key;
                  value = file.value;
                })
                |> lib.listToAttrs
              )
            )
            (
              let
                wrapperArgs = lib.escapeShellArgs makeWrapperArgs;
                bin = lib.escapeShellArg binName;
              in
              #bash
              ''
                mkdir -p $out
                lndir -silent ${package} $out
                ${paths |> lib.concatMapStringsSep "\n" (pkgPath: "lndir -silent ${pkgPath} $out")}

                ${
                  linkFiles
                  |> lib.concatMapStringsSep "\n" (file: ''
                    mkdir -p "$(dirname "$out/${file.name}")"
                    ln -sf ${lib.escapeShellArg file.value} "$out/${file.name}"
                  '')
                }

                ${
                  textFiles
                  |> lib.concatMapStringsSep "\n" (file: ''
                    install -Dm644 "''$${file.key}Path" "$out/${file.name}"
                  '')
                }

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
              ''
            );
      };
      options = {
        package = lib.mkOption {
          type = lib.types.package;
          description = "The main package to wrap.";
        };

        paths = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Additional packages to symlink into the output directory.";
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

        makeWrapperArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Raw arguments passed to makeWrapper/wrapProgram";
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
