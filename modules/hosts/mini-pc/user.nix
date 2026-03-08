{ self, inputs, ... }:
{
  flake.modules.nixos.user =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        overwriteBackup = true;
      };
      users = {
        users.${self.variables.username} = {
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
      environment.shells = with pkgs; [
        fish
        nushell
      ];
    };
}
