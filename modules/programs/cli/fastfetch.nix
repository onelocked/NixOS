{
  m.fastfetch =
    let
      esc = (builtins.fromJSON ''{ "value": "\u001b" }'').value;
    in
    {
      forte.fastfetch = {
        enable = true;
        settings = {
          "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
          logo = {
            source = "-";
            type = "raw";
            width = 20;
            padding = {
              top = 2;
              left = 2;
            };
          };
          display = {
            separator = " ┈➤ ";
          };
          modules = [
            "break"
            {
              type = "title";
              keyWidth = 10;
              format = "         ${esc}[38;2;197;192;255m{1}${esc}[38;2;168;200;240m@${esc}[38;2;200;176;232m{2}${esc}[0m";
            }
            {
              type = "custom";
              format = " ─────────────────────────── ";
            }
            {
              type = "os";
              key = " ";
              keyColor = "#cfd3e7";
            }
            {
              type = "cpu";
              key = " ";
              keyColor = "#f4a8b8";
            }
            {
              type = "gpu";
              key = "󰢮 ";
              keyColor = "#ff7a6b";
            }
            {
              type = "memory";
              key = " ";
              keyColor = "#b8db8c";
              format = "{1} / {2}";
            }
            {
              type = "wm";
              key = " ";
              keyColor = "#7d75c0";
            }
            {
              type = "terminal";
              key = " ";
              keyColor = "#f6d88a";
            }
            {
              type = "custom";
              format = " ─────────────────────────── ";
            }
            {
              type = "custom";
              format = "   ${esc}[31m  ${esc}[32m  ${esc}[33m  ${esc}[34m  ${esc}[35m  ${esc}[36m  ${esc}[37m  ${esc}[90m ";
            }
            "break"
          ];
        };
      };
    };
  m.default =
    {
      lib,
      birdee,
      pkgs,
      config,
      ...
    }:
    let
      cfg = config.forte.fastfetch;
      json = pkgs.formats.json { };
    in
    {
      config = lib.mkIf cfg.enable {
        environment.shellAliases.ff = "kitten icat -n --place 20x20@2x1 --scale-up --align left ${
          (pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/fleet-snowfluff.gif";
            hash = "sha256-Vz6QZrhr5c+ShiHJwxHFeyCXszWFvDjhKFm2CyQNAbo=";
          })
        } | ${lib.getExe cfg.package}";
      };

      options.forte.fastfetch = {
        enable = lib.mkEnableOption "fastfetch";
        package = lib.mkOption {
          type = lib.types.package;
          default = birdee.lib.wrapPackage (
            { config, ... }:
            {
              inherit pkgs;
              package = pkgs.fastfetch.minimal;
              flags = {
                "--config" = config.constructFiles.generatedConfig.path;
              };
              constructFiles.generatedConfig = {
                relPath = "config.jsonc";
                builder = ''mkdir -p "$(dirname "$2")" && cp ${json.generate "config.jsonc" cfg.settings} "$2"'';
              };
            }
          );
        };
        settings = lib.mkOption {
          inherit (json) type;
          default = { };
          description = "Fastfetch config options";
        };
      };
    };
}
