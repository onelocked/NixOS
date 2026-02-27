{ self, ... }:
{
  flake.nixosModules.onelock =
    { pkgs, ... }:
    {
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
