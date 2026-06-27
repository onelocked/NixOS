{
  exo.mods.desktop =
    {
      lib,
      hostName,
      constants,
      ...
    }:
    {
      config = lib.mkIf (hostName == "gaming-pc") {
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
    };
}
