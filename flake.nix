{
  outputs =
    { self, ... }:
    let
      inputs = (import ./.tack) // {
        inherit self;
      };
      inherit (inputs.nixpkgs) lib;

      rootPath = ./.;

      projectInput =
        system: input:
        [
          "packages"
          "legacyPackages"
          "devShells"
          "checks"
          "apps"
          "formatter"
        ]
        |> lib.filter (key: input ? ${key} && input.${key} ? ${system})
        |> lib.flip lib.genAttrs (key: input.${key}.${system});

      withSystem =
        system: f:
        f {
          inherit system inputs rootPath;
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          inputs' = inputs |> lib.mapAttrs (_: projectInput system);
          self' = projectInput system self;
        };

      #  Evaluate the top-level modules
      topEval = lib.evalModules {
        specialArgs = { inherit inputs withSystem rootPath; };
        modules =
          [
            ./modules
            ./hosts
            ./.secrets
          ]
          |> map (lib.fileset.fileFilter (file: file.hasExt "nix" && !lib.hasPrefix "_" file.name))
          |> lib.fileset.unions
          |> lib.fileset.toList;
      };

      # Evaluate omniSystem blocks for each system
      systemOutputs =
        topEval.config.systems
        |> lib.flip lib.genAttrs (
          system:
          withSystem system (
            specialArgs:
            (lib.evalModules {
              inherit specialArgs;
              modules = [
                topEval.config.omniSystem
                { config._module.freeformType = lib.types.lazyAttrsOf lib.types.unspecified; }
              ];
            }).config
          )
        );

      # Transpose system-dependent configurations to the top level
      transposed =
        systemOutputs
        |> lib.attrValues
        |> map lib.attrNames
        |> lib.flatten
        |> lib.unique
        |> lib.flip lib.genAttrs (
          key:
          topEval.config.systems
          |> lib.filter (system: systemOutputs.${system} ? ${key})
          |> lib.flip lib.genAttrs (system: systemOutputs.${system}.${key})
        );
    in
    topEval.config.flake // transposed;
}
