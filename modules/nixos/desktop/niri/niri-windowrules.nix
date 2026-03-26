{
  flake.modules.nixos.niri = {
    custom.programs.niri.settings = {
      window-rules = [
        {
          matches = [ { app-id = "FileChooser"; } ];
          default-column-width.fixed = 2263;
          default-window-height.fixed = 1273;
          open-focused = true;
          open-floating = true;
          opacity = 0.85;
          background-effect = {
            xray = true;
            blur = true;
          };
        }
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
          open-fullscreen = false;
          open-floating = true;
          default-column-width.fixed = 1945;
          default-window-height.fixed = 1095;
        }
        {
          matches = [ { app-id = "vesktop"; } ];
          open-on-workspace = "social";
          open-focused = false;
          default-column-width.proportion = 0.79;
        }
        {
          matches = [ { app-id = "zen-twilight"; } ];
          excludes = [
            {
              app-id = "zen-twilight";
              title = "Picture-in-Picture";
            }
            {
              app-id = "zen-twilight$";
              title = "Library";
            }
          ];
          tiled-state = true;
          default-column-width.proportion = 0.749;
          open-on-workspace = "browser";
        }
        {
          matches = [
            {
              app-id = "zen-twilight";
              title = "Picture-in-Picture";
            }
          ];
          open-floating = false;
          open-fullscreen = true;
        }
        {
          matches = [ { app-id = "zen-twilight"; } ];
          excludes = [
            {
              app-id = "zen-twilight";
              title = "YouTube";
            }
            {
              app-id = "zen-twilight";
              title = "TikTok";
            }
            {
              app-id = "zen-twilight";
              title = "Excalidraw";
            }
          ];
        }
        {
          matches = [
            {
              app-id = "zen-twilight";
              title = "Library";
            }
          ];
          open-floating = true;
          default-column-width.fixed = 1300;
          default-window-height.fixed = 900;
        }
      ];
    };
  };

}
