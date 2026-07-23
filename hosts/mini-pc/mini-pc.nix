{ config, ... }:
{
  exo.configurations = {
    mini-pc = {
      user = "onelock";
      hardware = "mini-pc";
      theme = "dark";
      modules = with config.exo.mods; [
        desktop
        media
        remote-access
      ];
    };
  };
}
