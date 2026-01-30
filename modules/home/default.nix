{ inputs, ... }:
{
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };
    home-manager.users.onelock = {
      imports = [ inputs.self.modules.homeManager.onelock ];
    };
  };
}
