{
  exo.mods.desktop =
    { config, lib, ... }:
    {
      services.blueman.enable = false;
      hardware.bluetooth = {
        enable = false;
        powerOnBoot = false;
        settings.General.Experimental = true;
      };
      forte.persist = lib.mkIf config.hardware.bluetooth.enable {
        root.directories = [ "/var/lib/bluetooth" ];
      };
    };
}
