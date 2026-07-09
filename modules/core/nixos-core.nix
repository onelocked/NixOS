{ inputs, ... }:
{
  exo.core = {
    imports = [ inputs.nixos-core.nixosModules.default ];
    system.nixos-core.enable = true;
  };
}
