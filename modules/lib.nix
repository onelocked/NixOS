{
  lib,
  self,
  inputs,
  ...
}:
{
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };
  config.flake.lib = {

    mkSystem =
      {
        nixosModules,
        system ? "x86_64-linux",
      }:
      let
        nixosModulesWithDefault = nixosModules ++ [ self.modules.nixos.default ];
      in
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = nixosModulesWithDefault;
      };
  };
}
