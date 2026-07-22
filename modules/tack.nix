{ config, lib, ... }:
{
  config = {

    tack = {
      inputs.tack = "gh:iynaix/tack/update-exclude-arg"; # TODO: remove once this PR is merged gh:manic-systems/tack
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
        pkgs,
        inputs,
        packages',
        ...
      }:
      let
        tomlFormat = (pkgs.formats.toml { }).generate;
        tackConfig = {
          inherit (config.tack) shorturls all_follow;
          inputs =
            config.tack.inputs
            |> lib.mapAttrs (
              _: val:
              {
                inherit (val) url;
              }
              // lib.optionalAttrs val.fetch { type = "fetch"; }
              // lib.optionalAttrs val.fixed { type = "fixed"; }
              // lib.optionalAttrs (val.exclude_follow != [ ]) { inherit (val) exclude_follow; }
            );
        };
        pinsToml = tomlFormat "pins.toml" tackConfig;

        finalInputs = config.tack.inputs |> lib.attrNames;
        prevInputs =
          inputs
          |> lib.attrNames
          |> lib.subtractLists (
            [
              "self"
              "__functor"
            ]
            ++ (config.tack.all_follow |> lib.attrNames |> lib.subtractLists finalInputs)
          );
        newInputs = finalInputs |> lib.subtractLists prevInputs |> lib.join " ";
        removedInputs = prevInputs |> lib.subtractLists finalInputs;
        hasChanges = newInputs != "" || removedInputs != [ ];
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

                  ${lib.optionalString (removedInputs != [ ]) ''
                    echo "Changes to .tack/pins.toml (some inputs were removed):"
                    delta --dark .tack/pins.toml "${pinsToml}" || true
                  ''}
                  ${lib.optionalString hasChanges ''
                    install -m 644 -D -T "${pinsToml}" .tack/pins.toml
                    echo "wrote .tack/pins.toml"
                  ''}
                  ${lib.optionalString (newInputs != "") "tack update ${newInputs}"}

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
    description = "Tack input manager configuration";
    default = { };
    type = lib.types.submodule {
      options = {
        shorturls = lib.mkOption {
          description = "Short URL patterns";
          type = lib.types.attrsOf lib.types.str;
        };
        all_follow = lib.mkOption {
          description = "Inputs that all other inputs should follow";
          type = lib.types.attrsOf lib.types.str;
        };
        inputs = lib.mkOption {
          description = "Tack inputs";
          default = { };
          type = lib.types.attrsOf (
            lib.types.coercedTo lib.types.str (url: { inherit url; }) (
              lib.types.submodule {
                options = {
                  url = lib.mkOption { type = lib.types.str; };
                  fetch = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                  };
                  fixed = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                  };
                  exclude_follow = lib.mkOption { type = lib.types.listOf lib.types.str; };
                };
              }
            )
          );
        };
      };
    };
  };
}
