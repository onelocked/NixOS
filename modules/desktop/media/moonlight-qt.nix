{
  exo.mods.desktop =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cfg = config.forte.moonlight-qt;
    in
    {
      config =
        lib.mkIf cfg.enable
        <| lib.mkMerge [
          {
            hj.packages = [ cfg.package ];
            forte.hyprland.lua.window-rules = # lua
              ''
                hl.window_rule({
                  name            = "Moonlight",
                  match           = { class = "com.moonlight_stream.Moonlight", title = "onelock - Moonlight" },
                  fullscreen      = false,
                  scrolling_width = 0.95,
                  content         = "game",
                  workspace       = "name:media silent",
                  immediate       = true,
                  no_shadow       = false,
                  opacity         = "1 override",
                  no_auto_hdr     = true,
                })
                hl.window_rule({
                  name             = "Moonlight-window",
                  match            = { class = "com.moonlight_stream.Moonlight", title = "negative:onelock - Moonlight" },
                  fullscreen       = false,
                  no_initial_focus = true,
                  suppress_event   = "fullscreen maximize activate activatefocus",
                  workspace       = "name:media silent",
                  decorate         = false,
                  opacity          = "1 override",
                })
              '';
            forte.persist.home.directories = [ ".config/Moonlight Game Streaming Project" ];
          }
          (lib.mkIf (config.forte.otter-launcher.enable) {
            forte.otter-launcher = {
              modules = [
                {
                  description = "pc";
                  "prefix" = "game";
                  cmd = "app2unit -- moonlight stream onelock desktop; exit";
                }
              ];
            };
          })
        ];
      options.forte.moonlight-qt = {
        enable = lib.mkEnableOption "moonlight-qt" // {
          default = config.desktop.media.enable;
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.moonlight-qt;
        };
      };
    };
}
