{
  exo.mods.desktop =
    { self', ... }:
    {
      forte.hyprland.plugins = [ self'.legacyPackages.scrolloverview ];
      forte.hyprland.lua.settings = # lua
        ''
          hl.config({
            plugin = {
              scrolloverview = {
                gesture_distance = 300,
                scale = 0.40,
                workspace_gap = 15,
                layout = "vertical",
                wallpaper = 0,
                blur = false,
                shadow = {
                  enabled = false,
                },
              },
            },
          })
          hl.bind("SUPER + G", function()
            hl.plugin.scrolloverview.overview("toggle all")
          end)
        '';
    };
}
