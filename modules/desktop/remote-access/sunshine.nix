{
  exo.mods.desktop =
    {
      config,
      lib,
      hostName,
      ...
    }:
    {
      services.sunshine = {
        enable = config.desktop.remote-access.enable;
        autoStart = if hostName != "gaming-pc" then false else true;
        capSysAdmin = true;
        openFirewall = true;
      };
      forte.persist.home = lib.mkIf config.services.sunshine.enable {
        directories = [ ".config/sunshine" ];
      };
    };
}
