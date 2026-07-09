{ inputs, ... }:
{
  exo.core =
    { lib, ... }:
    {
      imports = [ inputs.nix-index-database.nixosModules.default ];
      programs.command-not-found.enable = lib.mkForce false;
      programs.nix-index-database.comma.enable = true;
    };
}
