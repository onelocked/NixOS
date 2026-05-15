{
  lib,
  inputs,
  withSystem,
  config,
  ...
}:
{
  config = {
    forte.system = {
      mkSystem =
        {
          modules,
          system ? "x86_64-linux",
        }:
        withSystem system (
          { self', inputs', ... }:
          inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit self' inputs';
            };
            modules = modules ++ [ config.m.default ];
          }
        );
    };
  };
  options.forte.system = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };
}
