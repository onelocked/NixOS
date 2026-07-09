{
  outputs =
    { self, ... }:
    let
      tackInputs = import ./.tack;

      inherit (tackInputs.nixpkgs) lib;

      inputs = tackInputs // {
        inherit self;
      };

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
        |> map (key: {
          name = key;
          value = input.${key}.${system};
        })
        |> lib.listToAttrs;

      withSystem =
        system: f:
        f {
          inherit system inputs rootPath;
          pkgs = tackInputs.nixpkgs.legacyPackages.${system};
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
      # the output looks something like this
      # systemOutputs = { "x86_64-linux" = { packages = "pkg1"; devShells = "shell1"; }; }
      systemOutputs =
        topEval.config.systems
        |> map (system: {
          name = system;
          value = withSystem system (
            specialArgs:
            (lib.evalModules {
              inherit specialArgs;
              modules = [
                topEval.config.omniSystem
                { config._module.freeformType = lib.types.lazyAttrsOf lib.types.unspecified; }
              ];
            }).config
          );
        })
        |> lib.listToAttrs;

      # Transpose system-dependent configurations to the top level
      transposed =
        systemOutputs
        |> lib.attrValues
        |> map lib.attrNames
        |> lib.flatten
        |> lib.unique
        |> map (key: {
          name = key;
          value =
            topEval.config.systems
            |> lib.filter (system: systemOutputs.${system} ? ${key})
            |> map (system: {
              name = system;
              value = systemOutputs.${system}.${key};
            })
            |> lib.listToAttrs;
        })
        |> lib.listToAttrs;
    in
    topEval.config.flake // transposed;
}
