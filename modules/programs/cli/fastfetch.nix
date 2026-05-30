{
  m.fastfetch =
    {
      scheme,
      config,
      lib,
      pkgs,
      ...
    }:
    {
      forte.fastfetch =
        let
          esc = (builtins.fromJSON ''{ "value": "\u001b" }'').value;
          tux = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/tux.png";
            hash = "sha256-XbAnJefiU9FD2aOm3rit8Et0lfI7Itt5rqsFxm3AZk4=";
          };
        in
        {
          enable = true;
          settings = {
            "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
            logo = {
              source = tux;
              type = "kitty-direct";
              height = 9;
              width = 20;
              padding = {
                top = 1;
                left = 2;
              };
            }
            // lib.optionalAttrs (config.forte.theme.variant == "dark") {
              source = "-";
            };
            display = {
              separator = " ┈➤ ";
            };
            modules = with scheme.withHashtag; [
              {
                type = "title";
                keyWidth = 10;
                format = "         ${esc}[38;2;92;36;136m{1}${esc}[38;2;140;140;140m@${esc}[38;2;0;89;89m{2}${esc}[0m";
              }
              {
                type = "custom";
                format = " ─────────────────────────── ";
              }
              {
                type = "os";
                key = " ";
                keyColor = "${base0C}";
              }
              {
                type = "cpu";
                key = " ";
                keyColor = "${base0E}";
              }
              {
                type = "gpu";
                key = "󰢮 ";
                keyColor = "${base08}";
              }
              {
                type = "memory";
                key = " ";
                keyColor = "${base0B}";
                format = "{1} / {2}";
              }
              {
                type = "wm";
                key = " ";
                keyColor = "${base0D}";
              }
              {
                type = "terminal";
                key = " ";
                keyColor = "${base0A}";
              }
              {
                type = "custom";
                format = " ─────────────────────────── ";
              }
              {
                type = "custom";
                format = "   ${esc}[38;2;158;28;28m  ${esc}[38;2;36;102;40m  ${esc}[38;2;107;97;0m  ${esc}[38;2;16;88;122m  ${esc}[38;2;92;36;136m  ${esc}[38;2;0;89;89m  ${esc}[38;2;37;37;37m  ${esc}[38;2;140;140;140m ";
              }
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
      theme = config.forte.theme.variant;
    in
    {
      config = lib.mkIf cfg.enable {
        hj.packages = [ cfg.package ];
        environment.shellAliases.ff =
          if theme == "dark" then
            "kitten icat -n --place 20x20@2x1 --scale-up --align left ${
              (pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/fleet-snowfluff.gif";
                hash = "sha256-Vz6QZrhr5c+ShiHJwxHFeyCXszWFvDjhKFm2CyQNAbo=";
              })
            } | ${lib.getExe cfg.package}"
          else
            "${lib.getExe cfg.package}";
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
