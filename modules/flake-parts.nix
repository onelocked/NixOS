{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    (lib.mkAliasOptionModule [ "m" ] [ "flake" "modules" "nixos" ])
    inputs.flake-file.flakeModules.default
    (lib.mkAliasOptionModule [ "ff" ] [ "flake-file" "inputs" ])
  ];

  disabledModules = [ (inputs.flake-file + "/modules/flake-parts.nix") ];

  perSystem =
    { pkgs, ... }:
    let
      mkApp = f: {
        type = "app";
        program = lib.getExe (f pkgs);
      };
    in
    {
      apps = config.flake-file.apps |> lib.mapAttrs (_: mkApp);
    };

  systems = import inputs.systems;

  flake-file = {
    inputs = {
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      flake-file.url = "github:vic/flake-file";
      wrappers = {
        url = "github:BirdeeHub/nix-wrapper-modules";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    do-not-edit = "";
    outputs = # nix
      ''
        inputs@{ flake-parts, ... }:
        flake-parts.lib.mkFlake { inherit inputs; } {
          imports =
            with inputs.nixpkgs.lib;
            concatMap
              (
                dir:
                dir |> fileset.fileFilter (file: file.hasExt "nix" && !hasPrefix "_" file.name) |> fileset.toList
              )
              [
                ./modules
                ./hosts
                ./.secrets
              ];
        _module.args.rootPath = ./.;
        }
      '';
    description = "onelock's dendritic nixos flake configuration";
    style = {
      sortPriority.inputs = [
        "nixpkgs"
        "flake-parts"
        "flake-file"
        "wrappers"
      ];
    };
  };
}
