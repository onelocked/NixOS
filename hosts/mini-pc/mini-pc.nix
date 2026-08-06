{ config, ... }:
{
  exo.configurations = {
    mini-pc = {
      user = "onelock";
      hardware = "mini-pc";
      theme = "light";
      modules = with config.exo.mods; [
        desktop
        media
        remote-access
      ];
    };
  };
}
