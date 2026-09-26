{
  exo.mods.desktop = {
    forte.hyprland.lua.settings = # lua
      ''
        -- Scrindle Layout
        local function rebuild_state(ws)
            if not ws or ws.tiled_layout ~= "scrolling" then
                return
            end

            local count = #hl.get_windows({ workspace = ws, floating = false })

            if count == 1 then
                hl.dispatch(hl.dsp.layout("colresize " .. w169))
            elseif count <= 3 then
                hl.dispatch(hl.dsp.layout("fit all"))
            end
        end

        hl.on("window.open",      function() rebuild_state(hl.get_active_workspace()) end)
        hl.on("window.destroy",   function() rebuild_state(hl.get_active_workspace()) end)
        hl.on("workspace.active", function(ws) rebuild_state(ws) end)
        hl.on("config.reloaded",  function() rebuild_state(hl.get_active_workspace()) end)

        hl.on("window.move_to_workspace", function(_win, ws)
            rebuild_state(ws)
            rebuild_state(hl.get_active_workspace())
        end)
      '';
  };
}
