{
  m.default =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.forte.otter-launcher;
      theme = config.forte.theme.variant;
    in
    {
      config = lib.mkIf cfg.enable {
        forte.lib.otter-lib.cliamp-config = pkgs.writeText "otter-kitty.conf" ''
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

        forte.otter-launcher.modules = [
          {
            description = "cliamp";
            "prefix" = "mus";
            cmd = "app2unit -- kitty --app-id=CliampMusic -c ${config.forte.lib.otter-lib.cliamp-config} -e ${pkgs.cliamp}/bin/cliamp; exit";
          }
        ];
        forte.hyprland.lua.window-rules = # lua
          ''
            hl.window_rule({
              name             = "cliamp",
              match            = { class = "^CliampMusic$" },
              workspace        = "name:media silent",
              float            = true,
              size             = { ${if theme == "dark" then "780, 1090" else "780, 815"} },
            })

          '';
      };
    };
}
