{
  outputs =
    { self, ... }:
    let
      tackInputs = import ./.tack;

      inherit (tackInputs.nixpkgs) lib;

      inputs = tackInputs // {
        self = self';
      };

      self' = flakeOutputs // {
        inherit inputs;
        inherit (self) outPath;
      };

      importsList =
        with lib;
        [
          ./modules
          ./hosts
          ./.secrets
        ]
        |> map (fileset.fileFilter (file: file.hasExt "nix" && !hasPrefix "_" file.name))
        |> fileset.unions
        |> fileset.toList;

      flakeOutputs =
        tackInputs.flake-parts.lib.evalFlakeModule { inherit inputs; } {
          imports = importsList;
          _module.args.rootPath = ./.;
        }
        |> (eval: { inherit eval; } // eval.config.processedFlake);
    in
    flakeOutputs;
}
