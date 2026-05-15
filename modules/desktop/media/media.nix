{
  m.default =
    { pkgs, wrappers, ... }:
    {
      hj.packages = with pkgs; [
        moonlight-qt
        ayugram-desktop
        (wrappers.lib.wrapPackage {
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
          matches = [ { app-id = "com.moonlight_stream.Moonlight"; } ];
          open-on-workspace = "media";
          open-focused = true;
          open-fullscreen = false;
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
    };
}
