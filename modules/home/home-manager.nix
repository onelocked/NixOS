{
  self,
  inputs,
  ...
}:
{
  flake.modules.nixos.home-manager =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];
      users.users.${self.variables.username} = {
        isNormalUser = true;
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
      # Default shell
      users.defaultUserShell = pkgs.nushell;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
      };
    };
}
