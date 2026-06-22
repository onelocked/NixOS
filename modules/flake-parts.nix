{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.flake-file.flakeModules.default
    (lib.mkAliasOptionModule [ "ff" ] [ "flake-file" "inputs" ])
  ];

  disabledModules = [ (inputs.flake-file + "/modules/flake-parts.nix") ];

  config = {
    perSystem =
      { pkgs, ... }:
      {
        apps =
          config.flake-file.apps
          |> lib.mapAttrs (
            _: f: {
              type = "app";
              program = lib.getExe (f pkgs);
            }
          );
        formatter = pkgs.nixfmt-rs;
        _module.args = { inherit (inputs) birdee; };
      };
    exo.core.config._module.args = { inherit (inputs) birdee; };

    systems = import inputs.systems;

    flake-file = {
      inputs = {
        flake-file.url = "github:vic/flake-file";
        systems.url = "github:nix-systems/x86_64-linux";
        flake-parts = {
          url = "github:hercules-ci/flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs";
        };
        birdee = {
          url = "github:BirdeeHub/nix-wrapper-modules";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };

      do-not-edit = "";
      outputs = # nix
        ''
          inputs:
          inputs.flake-parts.lib.evalFlakeModule { inherit inputs; } {
            imports =
              with inputs.nixpkgs.lib;
              [
                ./modules
                ./hosts
                ./.secrets
              ]
              |> map (fileset.fileFilter (file: file.hasExt "nix" && !hasPrefix "_" file.name))
              |> fileset.unions
              |> fileset.toList;
            _module.args.rootPath = ./.;
          }
          |> (eval: { inherit eval; } // eval.config.processedFlake)
        '';
      style = {
        sortPriority.inputs = [
          "nixpkgs"
          "flake-parts"
          "flake-file"
        ];
      };
    };
  };
  options.exo = {
    mods = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
    };
    core = lib.mkOption {
      type = lib.types.deferredModule;
    };
    skeleton = lib.mkOption {
      type = lib.types.deferredModule;
    };
    hardware = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
    };
    pilot = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
    };
  };
}
