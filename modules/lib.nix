{
  lib,
  self,
  inputs,
  withSystem,
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
        modules,
        system ? "x86_64-linux",
      }:
      withSystem system (
        { self', inputs', ... }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self' inputs';
            inherit (inputs) wrappers;
          };
          modules = modules ++ [ self.modules.nixos.default ];
        }
      );
  };
}
