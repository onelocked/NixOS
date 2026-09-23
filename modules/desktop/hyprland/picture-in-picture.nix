{
  exo.mods.desktop = {
    forte.hyprland.lua.settings = # lua
      ''
        -- picture-in-picture
        local pipAddress = nil

        local function clearIfTracked(w)
          if w ~= nil and w.address ~= nil and w.address == pipAddress then
            pipAddress = nil
          end
        end

        hl.on("window.pin", function(w)
          if w == nil then return end
          if w.address == pipAddress and w.pin == false then
            pipAddress = nil
          end
        end)

        hl.on("window.close", function(w)
          clearIfTracked(w)
        end)

        hl.on("window.destroy", function(w)
          clearIfTracked(w)
        end)

        hl.bind("ALT + SHIFT + E", function()
          if pipAddress ~= nil then
            local target = "address:" .. pipAddress
            hl.dispatch(hl.dsp.window.pin({ window = target }))
            hl.dispatch(hl.dsp.window.float({ action = "disable", window = target }))
            hl.dispatch(hl.dsp.focus({ window = target }))
            pipAddress = nil
            return
          end

          local w = hl.get_active_window()
          if w == nil then return end

          hl.dispatch(hl.dsp.window.float({ action = "enable" }))
          hl.dispatch(hl.dsp.window.move({ x = 1, y = 1063 }))
          hl.dispatch(hl.dsp.window.resize({ x = 669, y = 376 }))
          hl.dispatch(hl.dsp.window.pin())
          hl.dispatch(hl.dsp.window.cycle_next({ tiled = true }))
          pipAddress = w.address
        end)

        --- don't focus pinned window on workspace switching
        hl.on("workspace.active", function(ws)
          local windows = hl.get_workspace_windows(ws)
          if windows == nil then return end

          local tiledWin = nil
          local activeIsPinnedFloating = false

          for _, w in ipairs(windows) do
            if not w.floating then
              tiledWin = w
            end
          end

          local active = hl.get_active_window()
          if active ~= nil and active.floating and active.pinned then
            activeIsPinnedFloating = true
          end

          if tiledWin ~= nil and activeIsPinnedFloating then
            hl.dispatch(hl.dsp.focus({ window = tiledWin }))
          end
        end)

        hl.bind("SUPER + mouse:274", hl.dsp.window.pin())

        hl.window_rule({
          match        = { pin = true },
          border_color = "rgb(FFFF00) rgba(FFFF0088)",
        })
      '';
  };
}
