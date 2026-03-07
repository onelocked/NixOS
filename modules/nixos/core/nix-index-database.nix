{ inputs, ... }:
{
  flake.modules.nixos.core = {
    imports = [ inputs.nix-index-database.nixosModules.default ];
    programs.nix-index-database = {
      comma.enable = true;
    };
  };
}
