{
  m.user =
    { config, constants, ... }:
    let
      password = config.sops.secrets."linux-password".path;
    in
    {
      sops.secrets = {
        "linux-password" = {
          neededForUsers = true; # Required for pre-user-creation
        };
      };
      users = {
        users.root.hashedPasswordFile = password;
        users.${constants.username} = {
          hashedPasswordFile = password;
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
