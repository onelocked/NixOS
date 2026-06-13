{ config, ... }:
{
  exo.configurations = {
    NixOS = {
      user = "onelock";
      hardware = "mini-pc";
      modules = [ config.exo.mods.desktop ];
      extraConfig = {
        forte.lan-mouse.enable = true;
        forte.rtp-audio.enable = true;
        services.sunshine.enable = true;
      };
    };
  };
}
