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

  config = {
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
        _module.args = { inherit (inputs) birdee; };
        formatter = pkgs.nixfmt-rs;
      };
    exo.core = {
      config._module.args = { inherit (inputs) birdee; };
      options.forte.lib = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        default = { };
      };
    };

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
      description = "nixos flake-parts configuration";
      style = {
        sortPriority.inputs = [
          "nixpkgs"
          "flake-parts"
          "flake-file"
        ];
      };
    };
  };

}
