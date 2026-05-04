{
  m.niri = {
    custom.programs.niri.settings = {
      window-rules = [
        {
          matches = [ { title = "Select what to share"; } ];
          open-floating = true;
          default-column-width.fixed = 500;
          default-window-height.fixed = 290;
          max-width = 500;
          max-height = 290;
        }
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
          matches = [ { app-id = "mpv"; } ];
          open-focused = true;
          open-fullscreen = true;
        }
        {
          matches = [ { app-id = "com.interversehq.qView"; } ];
          open-fullscreen = false;
          open-floating = true;
          max-height = 1200;
        }
        {
          matches = [ { app-id = "spotify"; } ];
          open-on-workspace = "media";
          open-focused = false;
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
  };
}
