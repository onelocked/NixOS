{ inputs, ... }:
{
  ff = {
    nixos-core = {
      url = "github:manic-systems/nixos-core";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  exo.core = {
    imports = [ inputs.nixos-core.nixosModules.default ];
    system.nixos-core.enable = true;
  };
}
