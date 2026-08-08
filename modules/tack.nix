{ config, lib, ... }:
{
  config = {
    tack = {
      inputs.tack = "gh:manic-systems/tack";
      shorturls = {
        gh = "github:{path}";
      };
      all_follow = {
        nixpkgs = "nixpkgs";
        systems = "systems";
        flake-compat = "flake-compat";
        flake-utils = "flake-utils";
        rust-overlay = "rust-overlay";
        treefmt-nix = "treefmt-nix";
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
        serialisedInputs =
          (
            removeAttrs config.tack.inputs [
              "fetch"
              "fixed"
            ]
            |> lib.mapAttrs (
              _:
              {
                url,
                type,
                exclude_follow,
                follows,
                ...
              }:
              lib.filterAttrs (name: value: value != null && value != { } && value != [ ]) {
                inherit
                  url
                  type
                  follows
                  exclude_follow
                  ;
              }
            )
          )
          // (
            config.tack.inputs.fetch
            |> lib.mapAttrs (
              _: url: {
                inherit url;
                type = "fetch";
              }
            )
          )
          // (
            config.tack.inputs.fixed
            |> lib.mapAttrs (
              _: url: {
                inherit url;
                type = "fixed";
              }
            )
          );
        tackConfig = {
          inherit (config.tack) shorturls all_follow;
          inputs = serialisedInputs;
        };

        # Read the current state of pins.toml to diff against
        prevPins = lib.importTOML (rootPath + /.tack/pins.toml);

        # Inputs that need tack update: either new or URL-changed
        updateInputs =
          tackConfig.inputs
          |> lib.attrNames
          |> lib.filter (
            name: !(prevPins.inputs ? ${name}) || prevPins.inputs.${name}.url != tackConfig.inputs.${name}.url
          )
          |> lib.join " ";
      in
      {
        apps.tack-rebuild = {
          type = "app";
          meta.description = "Sync tack pins on input changes, then nh os rebuild";
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
              text = # bash
                ''
                  if [[ ! -f .tack/pins.toml ]]; then
                    echo "Error: file not found: .tack/pins.toml" >&2
                    exit 1
                  fi

                  ${lib.optionalString (prevPins != tackConfig) ''
                    newPinsToml="${tackConfig |> tomlFormat "pins.toml"}"
                    delta --dark --side-by-side --line-numbers --diff-so-fancy .tack/pins.toml "$newPinsToml" || true
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

        inputs = lib.mkOption {
          default = { };
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
                    url = lib.mkOption {
                      type = lib.types.str;
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
