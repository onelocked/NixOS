{
  exo.mods.desktop =
    {
      lib,
      hostName,
      constants,
      ...
    }:
    {
      services.flatpak.enable = if hostName == "gaming-pc" then true else false;
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
}
