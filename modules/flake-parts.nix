{
  inputs,
  lib,
  ...
}:
{

  imports = [
    inputs.flake-parts.flakeModules.modules
    (lib.mkAliasOptionModule [ "m" ] [ "flake" "modules" "nixos" ])
    inputs.flake-file.flakeModules.default
    (lib.mkAliasOptionModule [ "ff" ] [ "flake-file" "inputs" ])
  ];

  systems = [ "x86_64-linux" ];

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
            ./modules
            |> fileset.fileFilter (file: file.hasExt "nix" && !hasPrefix "_" file.name)
            |> fileset.toList;
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
