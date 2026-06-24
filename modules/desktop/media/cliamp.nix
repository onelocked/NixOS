{
  exo.mods.desktop =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.forte.cliamp;
      theme = config.forte.theme.variant;
    in
    {
      config =
        lib.mkIf cfg.enable
        <| lib.mkMerge [
          (lib.mkIf (config.forte.otter-launcher.enable) {
            forte.otter-launcher.modules = [
              {
                description = "cliamp";
                prefix = "mus";
                cmd = "app2unit -- kitty --app-id=cliamp-music -c ${cfg.otter-cliamp-conf} -e ${cfg.package}/bin/cliamp; exit";
              }
            ];
          })
          {
            forte.hyprland.lua.window-rules = # lua
              ''
                hl.window_rule({
                  name             = "cliamp",
                  match            = { class = "^cliamp-music$" },
                  workspace        = "name:media silent",
                  float            = true,
                  size             = { ${if theme == "dark" then "780, 1090" else "780, 815"} },
                })
              '';
          }
        ];
      options.forte.cliamp = {
        enable = lib.mkEnableOption "cliamp" // {
          default = config.desktop.media.enable;
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.cliamp;
          defaultText = "pkgs.cliamp";
          description = "cliamp package";
        };
        otter-cliamp-conf = lib.mkOption {
          type = lib.types.package;
          default = pkgs.writeText "otter-cliamp.conf" ''
              allow_remote_control yes
              background_opacity 0.7
            ${
              lib.optionalString (theme == "dark") ''
                background_image        ${
                  (pkgs.fetchurl {
                    url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/aemeath-player.png";
                    hash = "sha256-IjywuR2gVYJK+6wwdV5bd48hjWLXgUKMOvApIHp+Ig0=";
                  })
                }
                background_image_layout scaled
                background_image_linear yes
                font_size               12
                window_padding_width    170 30 170 30
              ''
            };
          '';
          description = "cliamp config for otter-launcher";
        };
      };
    };
}
