{
  exo.mods.desktop =
    {
      lib,
      constants,
      config,
      ...
    }:
    let
      cfg = config.forte.flatpak;
    in
    {
      config = lib.mkIf cfg.enable {
        services.flatpak.enable = true;
        preservation.preserveAt = {
          "/games" = {
            commonMountOptions = [ "x-gvfs-hide" ];
            directories = lib.unique [ "/var/lib/flatpak" ];
            users.${constants.username}.directories = lib.unique [
              ".local/share/flatpak"
              ".cache/flatpak"
              ".var/app"
            ];
          };
        };
      };
      options.forte.flatpak = {
        enable = lib.mkEnableOption "Flatpak";
      };
    };
}
