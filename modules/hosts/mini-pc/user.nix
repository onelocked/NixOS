{ self, ... }:
let
  inherit (self.variables) username;
in
{
  m.user = {
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
