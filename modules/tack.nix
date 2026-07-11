{ config, lib, ... }:
{
  config = {
    exo.core =
      { pkgs, ... }:
      {
        hj.packages = [ pkgs.tack ];
        hj.environment.sessionVariables = {
          TACK_NIX_CONF_TOKENS = "1";
        };
      };
    omniSystem =
      { pkgs, ... }:
      let
        tomlFormat = pkgs.formats.toml { };
        pinsToml = tomlFormat.generate "pins.toml" {
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
          inputs =
            config.tack
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
      in
      {
        apps.tack-update = {
          type = "app";
          program = lib.getExe (
            pkgs.writeShellApplication {
              name = "tack-write";
              runtimeInputs = [
                pkgs.diffutils
                pkgs.difftastic
              ];
              text = ''
                if [ -f .tack/pins.toml ]; then
                  if ! diff -q .tack/pins.toml "${pinsToml}" >/dev/null; then
                    echo "Changes to .tack/pins.toml:"
                    difft .tack/pins.toml "${pinsToml}" || true
                  fi
                fi
                install -m 444 -D -T "${pinsToml}" .tack/pins.toml
                echo "wrote .tack/pins.toml"
              '';
            }
          );
        };
      };
  };
  options.tack = lib.mkOption {
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
            exclude_follow = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };
          };
        }
      )
    );
  };
}
