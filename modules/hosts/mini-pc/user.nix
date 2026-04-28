{
  m.user =
    { constants, ... }:
    {
      users = {
        users.${constants.username} = {
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
