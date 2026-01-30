{ inputs, ... }:
{
  flake.nixosConfigurations.nixos-onelock = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with inputs.self.modules.nixos; [
      onelock
    ];
  };
  # flake.homeConfigurations.nixos-onelock = inputs.home-manager.lib.homeManagerConfiguration {
  #   modules = [ inputs.self.modules.homeManager.home-manager ];
  # };
}
