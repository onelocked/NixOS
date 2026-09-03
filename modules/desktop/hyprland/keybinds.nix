{
  exo.mods.desktop =
    { pkgs, hostName, ... }:
    {
      forte.hyprland.lua.keybinds = # lua
        ''
          -- █                █       ▀             █
          -- █ ▄▀ ▄▀▀▀▄ █   █ █▀▀▀▄  ▀█   █▀▀▀▄ ▄▀▀▀█ ▄▀▀▀▀
          -- ██   █▀▀▀▀ █   █ █   █   █   █   █ █   █  ▀▀▀▄
          -- █ ▀▄ ▀▄▄▄▄ ▀▄▄▄█ █▄▄▄▀  ▄█▄  █   █ ▀▄▄▄█ ▄▄▄▄▀
          --             ▄▄▄▀
          -- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
          hl.bind("SUPER + Q", hl.dsp.window.close())

          -- screenshot
          hl.bind("Print", hl.dsp.exec_raw("${pkgs.wayfreeze}/bin/wayfreeze --after-freeze-cmd '${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | wl-copy; killall wayfreeze'"))

          -- fullscreen keybind
          hl.bind("SUPER + M", hl.dsp.window.fullscreen())

          -- cycle between floating and tiled
          hl.bind("ALT + TAB", function()
              local window = hl.get_active_window()
              if not window then return end

              if window.floating then
                  hl.dispatch(hl.dsp.window.cycle_next({ next = true, tiled = true, floating = false }))
              else
                  hl.dispatch(hl.dsp.window.cycle_next({ next = true, tiled = false, floating = true }))
              end
          end)

          -- toggle floating
          hl.bind("SUPER + SHIFT + W", function()
            local win = hl.get_active_window()
            if not win then return end

            if win.floating then
              hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
            else
              hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
              hl.dispatch(hl.dsp.window.resize({ x = 2100, y = 1200, relative = false }))
              hl.dispatch(hl.dsp.window.center())
            end
          end)

          -- Move focus with SUPER + arrow keys
          hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
          hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
          hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
          hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

          -- Switch workspaces with SUPER + [0-9]
          -- Move active window to a workspace with SUPER + SHIFT + [0-9]
          for i = 1, 10 do
            local key = i % 10 -- 10 maps to key 0
            hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
            hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
          end

          -- special workspace (scratchpad)
          hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
          hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

          -- focus through existing windows with SUPER + scroll
          hl.bind("SUPER + mouse_down", hl.dsp.focus({ direction = "right" }))
          hl.bind("SUPER + mouse_up", hl.dsp.focus({ direction = "left" }))

          -- Move/resize windows with SUPER + LMB/RMB and dragging
          hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
          hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

          hl.bind("SUPER + ALT + D", hl.dsp.exec_cmd("ddcutil setvcp 60 ${
            if hostName == "mini-pc" then "0x0f" else "0x11"
          }"),
            { locked = true, repeating = false })

          -- zoom
          local function toggle_zoom()
            local current = hl.get_config("cursor.zoom_factor")
            local new_zoom = (current == 1) and 3.5 or 1
            hl.config({ cursor = { zoom_factor = new_zoom } })
          end
          hl.bind("SUPER + Z", toggle_zoom)

          --                          ▀█    ▀█     ▀                      █       ▀             █
          -- ▄▀▀▀▀ ▄▀▀▀▄ █▄▀▀▀ ▄▀▀▀▄   █     █    ▀█   █▀▀▀▄ ▄▀▀▀█        █▀▀▀▄  ▀█   █▀▀▀▄ ▄▀▀▀█ ▄▀▀▀▀
          --  ▀▀▀▄ █     █     █   █   █     █     █   █   █ █   █        █   █   █   █   █ █   █  ▀▀▀▄
          -- ▄▄▄▄▀ ▀▄▄▄▀ █     ▀▄▄▄▀   ▀▄▄   ▀▄▄  ▄█▄  █   █ ▀▄▄▄█        █▄▄▄▀  ▄█▄  █   █ ▀▄▄▄█ ▄▄▄▄▀
          --                                                  ▄▄▄▀
          local function scrolling_only(fn)
            return function()
              local workspace = hl.get_active_workspace()
              if workspace and workspace.tiled_layout == "scrolling" then
                fn()
              end
            end
          end

          local function scrolling_binds(key, action)
            local fn = type(action) == "function" and action or function() hl.dispatch(action) end
            hl.bind(key, scrolling_only(fn))
          end

          scrolling_binds("SUPER + CTRL + left", hl.dsp.layout("swapcol l"))
          scrolling_binds("SUPER + CTRL + right", hl.dsp.layout("swapcol r"))
          scrolling_binds("SUPER + bracketright", hl.dsp.layout("consume_or_expel next"))
          scrolling_binds("SUPER + bracketleft", hl.dsp.layout("consume_or_expel prev"))
          hl.bind("SUPER + F", function()
              local ws = hl.get_active_workspace()

              if ws and (ws.name == "dev0" or ws.name == "dev1") and ws.windows < 4 then
                  hl.dispatch(hl.dsp.layout("fit all"))
              else
                  hl.dispatch(hl.dsp.layout("fit active"))
              end
          end)

          scrolling_binds("SUPER + R", function()
            hl.dispatch(hl.dsp.layout("colresize +conf"))
          end)

          scrolling_binds("SUPER + C", function()
            local prev = hl.get_config("scrolling.focus_fit_method")

            hl.config({ scrolling = { focus_fit_method = 0 } })
            hl.dispatch(hl.dsp.layout("center"))
            hl.config({ scrolling = { focus_fit_method = prev } })
          end)
        '';
    };
}
