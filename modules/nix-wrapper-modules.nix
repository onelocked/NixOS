{ inputs, ... }:
{
  ff.birdee = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  perSystem._module.args = { inherit (inputs) birdee; };
  m.default._module.args = { inherit (inputs) birdee; };
}
