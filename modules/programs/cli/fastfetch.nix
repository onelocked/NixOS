{
  m.fastfetch =
    { scheme, ... }:
    {
      forte.fastfetch =
        let
          esc = (builtins.fromJSON ''{ "value": "\u001b" }'').value;
        in
        with scheme.withHashtag;
        {
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
              {
                type = "title";
                keyWidth = 10;
                # Mapped to: Lavender (Username) @ Dark FG (At symbol) @ Blue (Hostname)
                # RGB Conversions: #183871 (24;56;113), #555555 (85;85;85), #10587a (16;88;122)
                format = "         ${esc}[38;2;92;36;136m{1}${esc}[38;2;140;140;140m@${esc}[38;2;0;89;89m{2}${esc}[0m";
              }
              {
                type = "custom";
                format = " ─────────────────────────── ";
              }
              {
                type = "os";
                key = " ";
                keyColor = "${base0C}"; # Mapped to Cyan (Deep Teal)
              }
              {
                type = "cpu";
                key = " ";
                keyColor = "${base0E}"; # Mapped to Mauve (Rich Violet)
              }
              {
                type = "gpu";
                key = "󰢮 ";
                keyColor = "${base08}"; # Mapped to Red (Dark Red)
              }
              {
                type = "memory";
                key = " ";
                keyColor = "${base0B}"; # Mapped to Green (Forest Green)
                format = "{1} / {2}";
              }
              {
                type = "wm";
                key = " ";
                keyColor = "${base0D}"; # Mapped to Blue for Niri
              }
              {
                type = "terminal";
                key = " ";
                keyColor = "${base0A}"; # Mapped to Yellow for Kitty/Foot
              }
              {
                type = "custom";
                format = " ─────────────────────────── ";
              }
              {
                type = "custom";
                # Mapped sequentially: Red, Green, Yellow, Blue, Mauve, Cyan, Default Foreground, Comments/Muted
                # Base Variables used: base08, base0B, base0A, base0D, base0E, base0C, base05, base03
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
