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
    hm = modules: {
      home-manager.users.${self.variables.username}.imports = modules;
    };

    mkSystem =
      {
        nixosModules,
        homeModules ? [ ],
      }:
      inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = nixosModules ++ lib.optional (homeModules != [ ]) (self.lib.hm homeModules);
      };
  };
}
