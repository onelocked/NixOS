{ inputs, ... }:
{
  flake.modules.nixos.overlays = {

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
