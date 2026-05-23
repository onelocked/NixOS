{
  m.default =
    {
      pkgs,
      birdee,
      config,
      ...
    }:
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
      forte.niri.settings.window-rules = [
        {
          matches = [ { app-id = "jellyfin-desktop"; } ];
          open-on-workspace = "media";
          open-focused = true;
          open-fullscreen = false;
        }
        {
          matches = [
            {
              app-id = "com.moonlight_stream.Moonlight";
              title = "Moonlight";
            }
          ];
          open-on-workspace = "media";
          open-focused = false;
          open-fullscreen = false;
        }
        {
          matches = [ { title = "onelock - Moonlight"; } ];
          open-on-workspace = "media";
          open-fullscreen = false;
          open-focused = true;
          default-column-width.proportion = 0.945;
        }
        {
          matches = [ { app-id = "com.ayugram.desktop"; } ];
          excludes = [
            {
              app-id = "com.ayugram.desktop";
              title = "^Media viewer$";
            }
          ];
          open-focused = false;
          default-column-width.proportion = 0.21;
          open-on-workspace = "social";
        }
        {
          matches = [
            {
              app-id = "com.ayugram.desktop";
              title = "^Media viewer$";
            }
          ];
          open-on-workspace = "social";
          open-fullscreen = true;
          open-focused = true;
        }
      ];
      forte.otter-launcher.settings = {
        modules = [
          {
            description = "pc";
            "prefix" = "game";
            cmd =
              config.forte.lib.resize 750 900
                "niri msg action spawn -- moonlight stream onelock desktop; exit";
          }
        ];
      };
    };
}
