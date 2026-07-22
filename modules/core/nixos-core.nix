{ inputs, ... }:
{
  tack.inputs.nixos-core = "gh:manic-systems/nixos-core";
  exo.core = {
    imports = [ inputs.nixos-core.nixosModules.default ];
    system.nixos-core.enable = true;
  };
}
