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
    };

  flake-file = {
    inputs.flake-file.url = "github:vic/flake-file";
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
}
