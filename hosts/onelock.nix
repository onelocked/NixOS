{ inputs, ... }:
{
  flake.nixosConfigurations.onelock = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with inputs.self.modules.nixos; [
      onelock
      core
      desktop
    ];
  };
}
