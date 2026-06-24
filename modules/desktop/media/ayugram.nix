{
  exo.mods.desktop =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.forte.ayugram;
    in
    {
      config = lib.mkIf cfg.enable {
        hj.packages = [ cfg.package ];
        forte.persist.home.directories = [ ".local/share/AyuGramDesktop" ];
        forte.hyprland.lua.window-rules = # lua
          ''
            hl.window_rule({
              name            = "Telegram",
              match           = { class = "com.ayugram.desktop", title = "negative:^Media viewer$" },
              fullscreen      = false,
              scrolling_width = 0.21,
              workspace       = "name:chat silent",
              suppress_event  = "fullscreen maximize activate activatefocus",
            })
            hl.window_rule({
              name             = "Telegram-media",
              match            = { class = "com.ayugram.desktop", title = "^Media viewer$" },
              workspace        = "name:chat silent",
              fullscreen       = false,
              fullscreen_state = "0 1",
              float            = true,
              size             = { 1900, 1100 },
            })
          '';
      };
      options.forte.ayugram = {
        enable = lib.mkEnableOption "ayugram" // {
          default = config.desktop.media.enable;
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.ayugram-desktop;
        };
      };
    };
}
