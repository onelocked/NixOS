{ inputs, ... }:
{
  ff.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  m.default =
    { lib, ... }:
    {
      imports = [ inputs.nix-index-database.nixosModules.default ];
      programs.command-not-found.enable = lib.mkForce false;
      programs.nix-index-database = {
        comma.enable = true;
      };
    };
}
