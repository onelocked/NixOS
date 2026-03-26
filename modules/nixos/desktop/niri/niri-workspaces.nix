{ self, ... }:
{
  flake.modules.nixos.niri =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cfg = config.home-manager.users.${self.variables.username};
    in
    {
      custom.programs.niri.settings.extraConfig = lib.mkMerge [
        # kdl
        ''
          workspace "browser" {
            layout {
                 center-focused-column "never"
                  default-column-width { proportion 0.749; }
                  preset-column-widths {
                  proportion 0.749
                  fixed 2871
              }
              }
             }

          workspace "coding" {
            layout {
                 center-focused-column "never"
                  preset-column-widths {
                  proportion 0.5
                  fixed 2488
              }
                default-column-width { fixed 2488; }

              }
             }

          workspace "social" {
             layout {
                  center-focused-column "never"
                  preset-column-widths {
                  proportion  0.79
                  proportion 0.21
              }
             }
          }
          workspace "media" {
            layout {
                 center-focused-column "never"
                  default-column-width { proportion 0.749;}
                  preset-column-widths {
                  proportion 0.749
              }
              }
             }
        ''
        (lib.mkAfter ''
          include optional=true "${cfg.xdg.configHome}/niri/config.kdl";
        '')
      ];
    };
}
