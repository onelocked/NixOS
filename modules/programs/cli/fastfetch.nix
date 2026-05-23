{
  m.fastfetch =
    {
      pkgs,
      lib,
      birdee,
      ...
    }:
    let
      fastfetch-config =
        pkgs.writeText "config.jsonc" # json
          ''
            {
              "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
              "logo": {
                "source": "-",
                "type": "raw",
                "width": 20,
                "padding": {
                  "top": 2,
                  "left": 2
                }
              },
              "display": {
                "separator": " ┈➤ "
              },
              "modules": [
                "break",
                {
                  "type": "title",
                  "keyWidth": 10,
                  "format": "         \u001b[38;2;197;192;255m{1}\u001b[38;2;168;200;240m@\u001b[38;2;200;176;232m{2}\u001b[0m"
                },
                {
                  "type": "custom",
                  "format": " ─────────────────────────── "
                },
                {
                  "type": "os",
                  "key": " ",
                  "keyColor": "#cfd3e7"
                },
                {
                  "type": "cpu",
                  "key": " ",
                  "keyColor": "#f4a8b8"
                },
                {
                  "type": "gpu",
                  "key": "󰢮 ",
                  "keyColor": "#ff7a6b"
                },
                {
                  "type": "memory",
                  "key": " ",
                  "keyColor": "#b8db8c",
                  "format": "{1} / {2}"
                },
                {
                  "type": "wm",
                  "key": " ",
                  "keyColor": "#7d75c0"
                },
                {
                  "type": "terminal",
                  "key": " ",
                  "keyColor": "#f6d88a"
                },
                {
                  "type": "custom",
                  "format": " ─────────────────────────── "
                },
                {
                  "type": "custom",
                  "format": "   \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m  \u001b[90m "
                },
                "break"
              ]
            }
          '';

      fastfetch = birdee.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.fastfetch.minimal;
        flags = {
          "--config" = "${fastfetch-config}";
        };
      };
      fleet-snowfluff = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/fleet-snowfluff.gif";
        hash = "sha256-Vz6QZrhr5c+ShiHJwxHFeyCXszWFvDjhKFm2CyQNAbo=";
      };
    in
    {
      environment.shellAliases.ff = "kitten icat -n --place 20x20@2x1 --scale-up --align left ${fleet-snowfluff} | ${lib.getExe fastfetch}";
      forte.otter-launcher.settings.modules = [
        {
          description = "fastfetch";
          "prefix" = "ff";
          cmd = "niri msg action set-window-width 800;niri msg action set-window-height 355;niri msg action center-window;sleep 0.2;kitten icat -n --place 20x20@2x1 --scale-up --align left ${fleet-snowfluff} | ${lib.getExe fastfetch};read -p ''";
        }
      ];
      forte.niri.settings.window-rules = [
        {
          matches = [ { app-id = "^fastfetch$"; } ];
          open-floating = true;
          opacity = 0.95;
          default-column-width.fixed = 755;
          default-window-height.fixed = 325;
        }
      ];
      hj.packages = [ fastfetch ];
    };
}
