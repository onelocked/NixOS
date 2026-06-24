{ config, ... }:
{
  exo.configurations = {
    mini-pc = {
      user = "onelock";
      hardware = "mini-pc";
      modules = with config.exo.mods; [ desktop ];
    };
  };
}
