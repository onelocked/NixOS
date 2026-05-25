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
    in
    {
      config = lib.mkIf cfg.enable {
        forte.lib.otter-lib.cliamp-config = pkgs.writeText "otter-kitty.conf" ''
          allow_remote_control yes
          background_opacity 1
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
        '';

        forte.otter-launcher.modules = [
          {
            description = "cliamp";
            "prefix" = "mus";
            cmd = "niri msg action spawn -- kitty --app-id=CliampMusic -c ${config.forte.lib.otter-lib.cliamp-config} -e ${pkgs.cliamp}/bin/cliamp; exit";
          }
        ];
        forte.niri.settings.window-rules = [
          {
            matches = [ { app-id = "^CliampMusic$"; } ];
            open-floating = true;
            default-column-width.fixed = 780;
            default-window-height.fixed = 1090;
          }
        ];
      };
    };
}
