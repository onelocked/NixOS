{ config, lib, ... }:
{
  config = {
    tack = {
      inputs.tack = {
        url = "gh:manic-systems/tack";
        group = "nix";
      };
      shorturls = {
        gh = "github:{path}";
      };
      tack.recomposable = "true";
      all_follow = {
        nixpkgs = "nixpkgs";
        systems = "systems";
        flake-compat = "flake-compat";
        flake-utils = "flake-utils";
        rust-overlay = "rust-overlay";
        treefmt-nix = "treefmt-nix";
        tack = "tack";
      };
      omit_inputs = [
        "flake-compat"
        "pre-commit-hooks"
        "treefmt-nix"
      ];
    };

    exo.core =
      { packages', ... }:
      {
        hj.packages = [ packages'.tack ];
        hj.environment.sessionVariables = {
          TACK_NIX_CONF_TOKENS = "1";
        };
        forte.persist.home.directories = [ ".cache/nix" ];
      };

    perSystem =
      {
        rootPath,
        pkgs,
        packages',
        ...
      }:
      let
        tomlFormat = (pkgs.formats.toml { }).generate;

        tackConfig = {
          inherit (config.tack)
            shorturls
            all_follow
            tack
            inputs
            ;
        }
        // lib.optionalAttrs (config.tack.omit_inputs != [ ]) {
          omit_inputs.names = config.tack.omit_inputs;
        };

        prevPins = lib.importTOML (rootPath + /.tack/pins.toml);

        updateInputs =
          config.tack.inputs
          |> lib.attrNames
          |> lib.filter (
            name: !(prevPins.inputs ? ${name}) || prevPins.inputs.${name}.url != config.tack.inputs.${name}.url
          )
          |> lib.join " ";

        removeInputs =
          (prevPins.inputs or { })
          |> lib.attrNames
          |> lib.filter (name: !(config.tack.inputs ? ${name}))
          |> map (remKey: "tack rm ${lib.escapeShellArg remKey}")
          |> lib.concatLines;

        prevPatches = name: prevPins.inputs.${name}.patches or [ ];
        currPatches = name: config.tack.inputs.${name}.patches or [ ];

        rmPatchCommands =
          config.tack.inputs
          |> lib.attrNames
          |> lib.concatMap (
            name:
            lib.subtractLists (currPatches name) (prevPatches name)
            |> map (patch: "tack patch rm ${lib.escapeShellArg name} ${lib.escapeShellArg patch}")
          )
          |> lib.concatLines;

        addPatchCommands =
          config.tack.inputs
          |> lib.attrNames
          |> lib.filter (name: lib.subtractLists (prevPatches name) (currPatches name) != [ ])
          |> map (name: "tack patch update ${lib.escapeShellArg name}")
          |> lib.concatLines;
      in
      {
        remotePackages.tack = packages'.tack;
        apps.tack-rebuild = {
          type = "app";
          meta.description = "Sync tack pins on input changes, can pass switch/boot/test arguments";
          program = lib.getExe (
            pkgs.writeShellApplication {
              name = "tack-rebuild";
              derivationArgs = {
                allowSubstitutes = false;
                preferLocalBuild = true;
              };
              runtimeInputs = [
                pkgs.delta
                packages'.tack
              ];
              text = ''
                if [[ ! -f .tack/pins.toml ]]; then
                  echo "Error: file not found: .tack/pins.toml" >&2
                  exit 1
                fi

                ${lib.optionalString (rmPatchCommands != "") rmPatchCommands}

                ${lib.optionalString (prevPins != tackConfig) ''
                  newPinsToml="${tackConfig |> tomlFormat "pins.toml"}"
                  delta --dark --side-by-side --line-numbers --diff-so-fancy .tack/pins.toml "$newPinsToml" || true

                  ${lib.optionalString (removeInputs != "") removeInputs}

                  install -m 644 -D -T "$newPinsToml" .tack/pins.toml
                  echo "wrote .tack/pins.toml"
                ''}
                ${lib.optionalString (updateInputs != "") "tack update ${updateInputs}"}
                ${lib.optionalString (addPatchCommands != "") addPatchCommands}

                if [[ $# -gt 0 ]]; then
                  nh os "$@"
                fi
              '';
            }
          );
        };
      };
  };

  options.tack = lib.mkOption {
    description = "Tack input manager configuration.";
    default = { };
    type = lib.types.submodule {
      options = {
        shorturls = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
        };

        all_follow = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
        };

        omit_inputs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        tack = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
        };

        inputs = lib.mkOption {
          default = { };
          apply = lib.mapAttrs (
            _: input: lib.filterAttrs (_: val: val != null && val != { } && val != [ ]) input
          );
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                url = lib.mkOption { type = lib.types.str; };
                submodules = lib.mkOption {
                  type = lib.types.nullOr lib.types.bool;
                  default = null;
                };
                frozen = lib.mkOption {
                  type = lib.types.nullOr lib.types.bool;
                  default = null;
                };
                group = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
                type = lib.mkOption {
                  type = lib.types.nullOr (
                    lib.types.enum [
                      "fetch"
                      "fixed"
                    ]
                  );
                  default = null;
                };
                follows = lib.mkOption {
                  type = lib.types.attrsOf lib.types.str;
                  default = { };
                };
                exclude_follow = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                };
                patches = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                };
              };
            }
          );
        };
      };
    };
  };
}
