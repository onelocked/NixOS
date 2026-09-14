{
  exo.mods.desktop =
    { self', ... }:
    {
      forte.hyprland.plugins = [ self'.legacyPackages.scrolloverview ];
      forte.hyprland.lua.settings = # lua
        ''
          local function isPluginLoaded(name)
            for _, p in ipairs(hl.get_loaded_plugins()) do
              if p.name == name then
                return true
              end
            end
            return false
          end

          hl.on("config.reloaded", function()
            if isPluginLoaded("scrolloverview") then
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
            end
          end)
        '';
    };
}
