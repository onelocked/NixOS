{ self, ... }:
{
  flake.modules.nixos.niri =
    {
      pkgs,
      lib,
      ...
    }:
    {
      custom.programs.niri.settings = {
        extraConfig = # kdl
          ''
            spawn-sh-at-startup "${pkgs.libsecret}/bin/secret-tool lookup app keyring-init || echo 'init' | secret-tool store --label='keyring-init' app keyring-init"
          '';
        prefer-no-csd = true;
        clipboard.disable-primary = true;

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        outputs."HDMI-A-1" = {
          mode = "3440x1440@99.982";
          scale = 1;
          transform = "normal";
          position._attrs = {
            x = 0;
            y = 0;
          };
        };

        window-rule = {
          geometry-corner-radius = 20;
          clip-to-geometry = true;
          draw-border-with-background = false;
        };

        overview = {
          zoom = 0.35;
          workspace-shadow.off = null;
        };

        layer-rules = [
          {
            matches = [ { namespace = "^noctalia-wallpaper*"; } ];
            place-within-backdrop = true;
          }
        ];

        hotkey-overlay.skip-at-startup = null;

        screenshot-path = self.variables.homedir + "/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

        debug.honor-xdg-activation-with-invalid-serial = null;

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
          disable-power-key-handling = null;
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
            natural-scroll = null;
            scroll-factor = 1.2;
            scroll-method = "on-button-down";
            scroll-button = 273;
            scroll-button-lock = null;
          };
        };

        cursor = {
          xcursor-theme = "Bibata-Modern-Ice";
          xcursor-size = 24;
        };

        gestures.hot-corners.off = null;

        layout = {
          background-color = "transparent";
          always-center-single-column = null;
          gaps = 9;
          center-focused-column = "on-overflow";
          preset-column-widths = [
            { fixed = 2489; }
            { fixed = 871; }
          ];
          default-column-width.fixed = 2489;
          focus-ring = {
            off = null;
            width = 0.5;
          };
          shadow = {
            on = null;
            draw-behind-window = true;
            softness = 50;
            spread = 5;
            offset._attrs = {
              x = 0;
              y = 0;
            };
            color = "#000000";
          };
        };
      };
    };
}
