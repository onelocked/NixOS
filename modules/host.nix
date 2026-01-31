{ inputs, ... }:
{
  flake.nixosConfigurations = {
    NixOS = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = with inputs.self.modules.nixos; [
        hardware
        amdgpu
        core
        desktop
        home-manager
      ];
    };
  };
}
