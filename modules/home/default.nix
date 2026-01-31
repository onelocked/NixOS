{
  inputs,
  ...
}:
{
  flake.modules.nixos.home-manager = {
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
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };
    home-manager.users.onelock = {
      imports = with inputs.self.modules.homeManager; [
        settings
        xdg
        nh
        cli
        vicinae
        quickshell
      ];
    };
  };
}
