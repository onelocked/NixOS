{
  exo.mods.remote-access =
    {
      config,
      lib,
      hostName,
      ...
    }:
    {
      services.sunshine = {
        enable = true;
        autoStart = if hostName != "lucatiel" then false else true;
        capSysAdmin = true;
        openFirewall = true;
      };
      forte.persist.home = lib.mkIf config.services.sunshine.enable {
        directories = [ ".config/sunshine" ];
      };
    };
}
