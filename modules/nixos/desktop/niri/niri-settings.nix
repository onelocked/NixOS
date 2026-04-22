{ self, ... }:
{
  m.niri =
    {
      pkgs,
      lib,
      ...
    }:
    let
      set = _: { };
    in
    {
      custom.programs.niri.settings = {
        extraConfig = # kdl
          ''spawn-sh-at-startup "${pkgs.libsecret}/bin/secret-tool lookup app keyring-init || echo 'init' | secret-tool store --label='keyring-init' app keyring-init" '';
        prefer-no-csd = true;
        clipboard.disable-primary = true;

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        outputs."HDMI-A-1" = {
          mode = "3440x1440@99.982";
          scale = 1;
          transform = "normal";
          position = _: {
            props = {
              x = 0;
              y = 0;
            };
            content = { };
          };
        };

        window-rule = {
          clip-to-geometry = true;
          draw-border-with-background = false;
        };

        overview = {
          zoom = 0.35;
          workspace-shadow.off = set;
        };

        layer-rules = [
          {
            matches = [ { namespace = "^awww-daemon$"; } ];
            place-within-backdrop = true;
          }
        ];

        hotkey-overlay.skip-at-startup = set;

        screenshot-path = self.variables.homedir + "/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

        debug.honor-xdg-activation-with-invalid-serial = set;

        recent-windows = {
          debounce-ms = 750;
          open-delay-ms = 250;
          highlight = {
            active-color = "#999999ff";
            urgent-color = "#ff9999ff";
            padding = 15;
            corner-radius = 20;
          };
          previews = {
            max-height = 480;
            max-scale = 0.5;
          };
        };

        input = {
          mod-key = "Super";
          mod-key-nested = "Alt";
          disable-power-key-handling = set;
          keyboard = {
            repeat-rate = 40;
            repeat-delay = 370;
            xkb = {
              layout = "us,ru";
            };
            track-layout = "global";
          };
          mouse = {
            accel-profile = "flat";
            natural-scroll = set;
            scroll-factor = 1.2;
            scroll-method = "on-button-down";
            scroll-button = 273;
            scroll-button-lock = set;
          };
        };

        cursor = {
          xcursor-theme = "Bibata-Modern-Ice";
          xcursor-size = 24;
        };

        gestures.hot-corners.off = set;

        layout = {
          empty-workspace-above-first = set;
          background-color = "transparent";
          always-center-single-column = set;
          gaps = 9;
          center-focused-column = "on-overflow";
          preset-column-widths = [
            { fixed = 2489; }
            { fixed = 871; }
          ];
          default-column-width.fixed = 2489;
          focus-ring = {
            off = set;
            width = 0.5;
          };
          shadow = {
            on = set;
            draw-behind-window = true;
            softness = 50;
            spread = 5;
            offset = _: {
              props = {
                x = 0;
                y = 0;
              };
              content = { };
            };
            color = "#000000";
          };
        };
      };
    };
}
