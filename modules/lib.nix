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
        modules,
        system ? "x86_64-linux",
      }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = modules ++ [ self.modules.nixos.default ];
      };
  };
}
