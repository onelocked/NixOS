{ self, ... }:
{
  flake.nixosModules.onelock =
    { pkgs, config, ... }:
    {
      users = {
        defaultUserShell = pkgs.${self.variables.shell};
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
      environment.shells = [ config.users.defaultUserShell ]; # Default shell
    };
}
