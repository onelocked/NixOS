{
  exo.mods.media =
    {
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
        forte.persist.home.directories = [
          ".cache/jellium-desktop"
          ".config/jellium-desktop"
        ];
        forte.hyprland.lua.window-rules = # lua
          ''
            hl.window_rule({
              name             = "jellium-desktop",
              match            = { class = "net.nullsum.JelliumDesktop" },
              workspace        = "name:media",
              fullscreen_state = "0 3",
              opacity          = "1 override",
            })
          '';
      };

      options.forte.jellyfin-desktop = {
        enable = lib.mkEnableOption "jellium-desktop" // {
          default = false;
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.jellium-desktop; # FIX: enable the module once this is merged https://github.com/NixOS/nixpkgs/pull/546102
        };
      };
    };
}
