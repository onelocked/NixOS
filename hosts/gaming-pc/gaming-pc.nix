{ config, ... }:
{
  exo.configurations = {
    gaming-pc = {
      user = "onelock";
      hardware = "gaming-pc";
      theme = "dark";
      modules = with config.exo.mods; [
        desktop
        remote-access
        gaming
      ];
      extraConfig = {
        forte = {
          flatpak.enable = true;
          openssh.enable = true;
          nfs-share.enable = true;
        };
      };
    };
  };
}
