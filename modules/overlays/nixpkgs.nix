{ inputs, ... }:
{
  flake.nixosModules.overlays = {

    nixpkgs = {

      overlays = [
        (
          final: prev:
          import ../../pkgs {
            pkgs = final;
            inherit inputs;
          }
        )
      ];
    };
  };
}
