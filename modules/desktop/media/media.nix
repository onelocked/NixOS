{
  m.default =
    { pkgs, birdee, ... }:
    {
      hj.packages = with pkgs; [
        moonlight-qt
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


          hl.window_rule({
            name        = "Moonlight",
            match       = { class = "com.moonlight_stream.Moonlight", title = "onelock - Moonlight" },
            fullscreen  = true,
            content     = "game",
            workspace   = "name:media silent",
            immediate   = true,
            no_shadow   = true,
            opacity     = "1 override",
            no_auto_hdr = true,
          })
          hl.window_rule({
            name             = "Moonlight-window",
            match            = { class = "com.moonlight_stream.Moonlight", title = "negative:onelock - Moonlight" },
            fullscreen       = false,
            no_initial_focus = true,
            suppress_event   = "fullscreen maximize activate activatefocus",
            workspace        = "special:hidden silent",
            decorate         = false,
            opacity          = "1 override",
          })
        '';
      forte.otter-launcher = {
        modules = [
          {
            description = "pc";
            "prefix" = "game";
            cmd = "app2unit -- moonlight stream onelock desktop; exit";
          }
        ];
      };
    };
}
