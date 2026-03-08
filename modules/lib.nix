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
    hm = username: modules: {
      home-manager.users.${username}.imports = modules;
    };
    mkSystem =
      {
        nixosModules,
        homeModules ? [ ],
        username ? self.variables.username,
        system ? "x86_64-linux",
      }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = nixosModules ++ lib.optional (homeModules != [ ]) (self.lib.hm username homeModules);
      };
  };
}
