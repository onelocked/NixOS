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

    mkHomeModules = groups: lib.flatten (lib.attrValues groups);

    mkSystem =
      {
        nixosModules,
        homeModules ? { },
        username ? self.variables.username,
        system ? "x86_64-linux",
      }:
      let
        flatHome = self.lib.mkHomeModules homeModules;
        flatHomeWithDefault = flatHome ++ [ self.modules.homeManager.default ];
        nixosModulesWithDefault = nixosModules ++ [ self.modules.nixos.default ];
      in
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules =
          nixosModulesWithDefault
          ++ lib.optional (flatHomeWithDefault != [ ]) (self.lib.hm username flatHomeWithDefault);
      };
  };
}
