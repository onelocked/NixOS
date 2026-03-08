{ inputs, ... }:
{
  flake.modules.nixos.default = {
    imports = [ inputs.nix-index-database.nixosModules.default ];
    programs.nix-index-database = {
      comma.enable = true;
    };
  };
}
