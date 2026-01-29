{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  users.users.${config.constants.username} = {
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
  users.defaultUserShell = pkgs.${config.constants.shell};
}
