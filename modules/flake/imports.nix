{ inputs, ... }:
{
  flake.modules.nixos.core = {
    imports = [ inputs.self.modules.nixos.constants ];
  };

  flake.modules.nixos.home-manager = {
    imports = [ inputs.self.modules.nixos.constants ];
  };
}
