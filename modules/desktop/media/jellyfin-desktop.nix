{
  exo.mods.desktop =
    {
      birdee,
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.forte.jellyfin-desktop;
    in
    {
      config = lib.mkIf cfg.enable {
        hj.packages = [ cfg.package ];
        forte.persist.home.directories = [ ".local/share/jellyfin-desktop" ];
        forte.hyprland.lua.window-rules = # lua
          ''
            hl.window_rule({
              name             = "jellyfin-desktop",
              match            = { class = "jellyfin-desktop" },
              workspace        = "name:media",
              fullscreen_state = "0 3",
              opacity          = "1 override",
            })
          '';
      };

      options.forte.jellyfin-desktop = {
        enable = lib.mkEnableOption "jellyfin-desktop" // {
          default = config.desktop.media.enable;
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = birdee.lib.wrapPackage {
            inherit pkgs;
            package = pkgs.jellyfin-desktop;
            flags = {
              "--platform" = "xcb";
            };
          };
        };
      };
    };
}
