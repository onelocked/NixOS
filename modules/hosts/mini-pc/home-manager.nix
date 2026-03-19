{ self, inputs, ... }:
let
  inherit (self.variables) username homedir stateVersion;
in
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.homeManager.default = {
    home = {
      username = username;
      homeDirectory = homedir;
      stateVersion = stateVersion;
    };
  };
  flake.modules.nixos.user = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      overwriteBackup = true;
    };
    users = {
      users.${username} = {
        isNormalUser = true;
        useDefaultShell = true;
        extraGroups = [
          "networkmanager"
          "wheel"
          "kvm"
          "input"
          "disk"
          "libvirtd"
          "video"
          "audio"
        ];
      };
    };
  };
}
