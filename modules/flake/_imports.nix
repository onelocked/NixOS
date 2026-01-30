{ inputs, ... }:
{
  flake.modules.nixos.core = {
    imports = [ inputs.self.modules.generic.constants ];
  };
  flake.modules.homeManager.onelock = {
    imports = [ inputs.self.modules.generic.constants ];
  };
}
