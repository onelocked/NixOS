{ inputs, ... }:
{
  flake.modules.nixos.onelock = {
    imports = [
      inputs.self.modules.nixos.hardware
      inputs.self.modules.nixos.core
      inputs.self.modules.nixos.home-manager
    ];
  };
}
