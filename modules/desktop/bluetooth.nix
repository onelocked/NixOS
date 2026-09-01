{
  exo.mods.desktop =
    { config, lib, ... }:
    let
      cfg = config.forte.bluetooth;
    in
    {
      config = lib.mkIf cfg.enable {
        services.blueman.enable = true;
        forte.persist.root.directories = [ "/var/lib/bluetooth" ];
        hardware.bluetooth = {
          enable = true;
          powerOnBoot = true;
          settings.General.Experimental = true;
        };
      };
      options.forte.bluetooth.enable = lib.mkEnableOption "bluetooth";
    };
}
