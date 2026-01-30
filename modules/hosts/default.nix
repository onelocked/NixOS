{ inputs, ... }:
{
  flake.nixosConfigurations = {
    NixOS = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.self.modules.nixos.onelock
      ];
    };
  };
}
