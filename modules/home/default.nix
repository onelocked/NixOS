{
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
      users.users.onelock = {
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
      home-manager.users.onelock = {
        imports = with inputs.self.modules.homeManager; [
          onelock
          xdg
          nh
          cli
          vicinae
          quickshell
        ];
      };
    };
}
