{ config, lib, ... }:
{
  config = {
    tack = {
      inputs.tack = "gh:manic-systems/tack";
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
          |> map (remKey: "tack rm ${remKey}")
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

                ${lib.optionalString (prevPins != tackConfig) ''
                  newPinsToml="${tackConfig |> tomlFormat "pins.toml"}"
                  delta --dark --side-by-side --line-numbers --diff-so-fancy .tack/pins.toml "$newPinsToml" || true

                  ${lib.optionalString (removeInputs != "") removeInputs}

                  install -m 644 -D -T "$newPinsToml" .tack/pins.toml
                  echo "wrote .tack/pins.toml"
                ''}
                ${lib.optionalString (updateInputs != "") "tack update ${updateInputs}"}

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

        tack = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
        };

        inputs = lib.mkOption {
          default = { };
          apply =
            rawInputs:
            let
              standard =
                removeAttrs rawInputs [
                  "fetch"
                  "fixed"
                ]
                |> lib.mapAttrs (
                  _: v:
                  lib.filterAttrs (name: val: val != null && val != { } && val != [ ]) {
                    inherit (v)
                      url
                      type
                      follows
                      exclude_follow
                      ;
                  }
                );
              fetch =
                (rawInputs.fetch or { })
                |> lib.mapAttrs (
                  _: url: {
                    inherit url;
                    type = "fetch";
                  }
                );
              fixed =
                (rawInputs.fixed or { })
                |> lib.mapAttrs (
                  _: url: {
                    inherit url;
                    type = "fixed";
                  }
                );
            in
            standard // fetch // fixed;

          type = lib.types.submodule {
            options = {
              fetch = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = { };
                description = "Shorthand for defining multiple fetch inputs";
              };
              fixed = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = { };
                description = "Shorthand for defining multiple fixed inputs";
              };
            };
            freeformType = lib.types.attrsOf (
              lib.types.coercedTo lib.types.str (url: { inherit url; }) (
                lib.types.submodule {
                  options = {
                    url = lib.mkOption { type = lib.types.str; };
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
                  };
                }
              )
            );
          };
        };
      };
    };
  };
}
