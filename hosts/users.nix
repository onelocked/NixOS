{
  exo.core =
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
  exo.pilot.onelock =
    let
      constants = {
        username = "onelock";
        homedir = "/home/onelock";
        locale = "en_GB.UTF-8";
        timezone = "Europe/London";
        stateVersion = "25.11";
        terminal = "kitty.desktop";
      };
    in
    {
      _module.args = { inherit constants; };
    };
}
