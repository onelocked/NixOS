{
  exo.mods.desktop =
    { pkgs, birdee, ... }:
    {
      hj.packages = with pkgs; [
        ayugram-desktop
        (birdee.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.jellyfin-desktop;
          flags = {
            "--platform" = "xcb";
          };
        })
      ];
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

          hl.window_rule({
            name             = "jellyfin-desktop",
            match            = { class = "jellyfin-desktop" },
            workspace        = "name:media",
            fullscreen_state = "0 3",
            opacity          = "1 override",
          })

        '';

      forte.persist.home.directories = [ ".local/share/jellyfin-desktop" ];
    };
}
