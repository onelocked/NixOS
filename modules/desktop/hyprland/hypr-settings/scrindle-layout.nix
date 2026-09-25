{
  exo.mods.desktop = {
    forte.hyprland.lua.settings = # lua
      ''
        -- Scrindle Layout
        -- scroll behave like dwindle for first 4 windows
        local count_tiled_windows = function(ws)
          local window_count = 0
          for _, w in pairs(hl.get_windows()) do
            if not w.floating and w.workspace == ws then
              window_count = window_count + 1
            end
          end
          return window_count
        end

        local function is_target_ws(ws)
          return ws.name == "2" or ws.name == "3"
        end

        hl.on("window.open_early", function(w)
          if w.floating then return end
          local ws = w.workspace
          if not ws then return end
          if not is_target_ws(ws) then return end
          if ws.tiled_layout ~= "scrolling" then return end

          local count = count_tiled_windows(ws)
          -- ws.windows here is the count BEFORE the new window is added
          if count % 4 == 0 then
            hl.dispatch(hl.dsp.layout("inhibit_scroll 1"))
          end
        end)

        hl.on("window.open", function(w)
          if w.floating then return end
          local ws = w.workspace
          if not ws then return end
          if not is_target_ws(ws) then return end
          if ws.tiled_layout ~= "scrolling" then return end

          local count = count_tiled_windows(ws)

          if count == 2 or count == 3 then
            hl.dispatch(hl.dsp.layout("fit all"))
          elseif count % 4 == 0 then
            -- Explicitly focus the new window first
            hl.dispatch(hl.dsp.focus({ window = w }))
            hl.dispatch(hl.dsp.layout("focus l"))
            hl.dispatch(hl.dsp.layout("consume"))
            hl.dispatch(hl.dsp.layout("focus d"))
            if count == 4 then
              hl.dispatch(hl.dsp.layout("fit all"))
            end
          end
          hl.dispatch(hl.dsp.layout("inhibit_scroll 0"))
        end)

        -- when closing windows resize them and make them fit the screen, single window is always column width 0.71
        hl.on("window.destroy", function()
          local ws = hl.get_active_workspace()
          if not ws then return end
          if not is_target_ws(ws) then return end
          if ws.tiled_layout ~= "scrolling" then return end

          local count = count_tiled_windows(ws)
          if count == 1 then
            hl.dispatch(hl.dsp.layout("colresize 0.7111"))
          elseif count == 2 or count == 3 then
            hl.dispatch(hl.dsp.layout("fit all"))
          end
        end)
      '';
  };
}
