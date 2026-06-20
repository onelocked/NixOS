{
  exo.mods.desktop =
    { pkgs, ... }:
    {
      forte.hyprland.lua.keybinds = # lua
        ''
          -- scrolling dynamic column width based on workspace
          local workspace_widths = {
            ["web"] = { 0.711, 0.93 },
            ["dev"] = { 0.3333, 0.5, 0.71 },
          }
          local default_widths = { 0.3, 0.5, 0.71 }
          local cycle_idx = 0
          local function apply_workspace_widths(ws_name_or_id)
            local safe_key = tostring(ws_name_or_id or "")
            local widths_to_apply = workspace_widths[safe_key] or default_widths

            hl.config({
              scrolling = {
                explicit_column_widths = table.concat(widths_to_apply, ", ")
              }
            })
          end

          hl.on("workspace.active", function(ws)
            if ws then apply_workspace_widths(ws.name or ws.id) end
          end)

          local current_ws = hl.get_active_workspace()
          if current_ws then apply_workspace_widths(current_ws.name or current_ws.id) end


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



          -- switch layouts
          hl.bind("SUPER + tab", function()
            local workspace   = hl.get_active_workspace()
            if not workspace then return end

            -- local layouts     = { "scrolling", "dwindle" }
            local layouts = {
              ["dwindle"] = "scrolling",
              ["scrolling"] =  "dwindle"
            }

            local next_layout = layouts[workspace.tiled_layout]
            if not next_layout then return end

            hl.workspace_rule({ workspace = "name:" .. workspace.name, layout = next_layout })

            if next_layout == "scrolling" then
              local prev = hl.get_config("scrolling.focus_fit_method")
              hl.config({ scrolling = { focus_fit_method = 0 } })
              hl.timer(function()
                hl.config({ scrolling = { focus_fit_method = prev } })
              end, { timeout = 50, type = "oneshot" })
            end
          end)

          -- alt+ tab overview

          hl.layout.register("grid", {
            recalculate = function(ctx)
              local n = #ctx.targets
              if n == 0 then return end
              local cols = math.ceil(math.sqrt(n))
              for i, target in ipairs(ctx.targets) do
                target:place(ctx:grid_cell(i, cols))
              end
            end,
          })

          local overview_origin_window = nil
          local overview_origin_layout = nil

          local function exit_overview(select)
            local workspace = hl.get_active_workspace()
            if not workspace then return end

            local restore_layout = overview_origin_layout or "scrolling"

            hl.workspace_rule({ workspace = "name:" .. workspace.name, layout = restore_layout })
            hl.dispatch(hl.dsp.submap("reset"))

            if not select then
              -- Escape key restore original window focus first
              if overview_origin_window then
                hl.dispatch(hl.dsp.focus({ window = overview_origin_window }))
              end
            end

            -- center in scrolling
            if restore_layout == "scrolling" then
              local prev = hl.get_config("scrolling.focus_fit_method")
              hl.config({ scrolling = { focus_fit_method = 0 } })
              hl.timer(function()
                hl.config({ scrolling = { focus_fit_method = prev } })
              end, { timeout = 50, type = "oneshot" })
            end

            overview_origin_window = nil
            overview_origin_layout = nil
          end

          hl.define_submap("overview", function()
            hl.bind("left", hl.dsp.focus({ direction = "left" }), { repeating = true })
            hl.bind("right", hl.dsp.focus({ direction = "right" }), { repeating = true })
            hl.bind("up", hl.dsp.focus({ direction = "up" }), { repeating = true })
            hl.bind("down", hl.dsp.focus({ direction = "down" }), { repeating = true })
            hl.bind("return", function() exit_overview(true) end)
            hl.bind("escape", function() exit_overview(false) end)
          end)

          hl.bind("ALT + TAB", function()
              local workspace = hl.get_active_workspace()
              if not workspace then return end

              overview_origin_window = hl.get_active_window()
              overview_origin_layout = workspace.tiled_layout

              hl.workspace_rule({ workspace = "name:" .. workspace.name, layout = "lua:grid" })
              hl.dispatch(hl.dsp.submap("overview"))
          end, { long_press = true })


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

          -- quickshell keybinds
          hl.bind("ALT + SHIFT + equal", hl.dsp.exec_raw("qs ipc call brightness increase"),
            { locked = true, repeating = false })

          hl.bind("ALT + SHIFT + minus", hl.dsp.exec_raw("qs ipc call brightness decrease"),
            { locked = true, repeating = false })

          hl.bind("ALT + SHIFT + W", hl.dsp.exec_raw("qs ipc call WallpaperPanel toggle"),
            { locked = true, repeating = false })

          -- disable side mouse buttons
          hl.bind("mouse:276", hl.dsp.no_op())
          hl.bind("mouse:275", hl.dsp.no_op())

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
            if not ws or ws.tiled_layout ~= "scrolling" then return end

            if ws.name == "dev" then
              hl.dispatch(hl.dsp.layout("fit all"))
            else
              hl.dispatch(hl.dsp.layout("fit active"))
            end
          end)

          scrolling_binds("SUPER" .. " + R", function()
            -- Find out what workspace we are currently on
            local ws = hl.get_active_workspace()
            local safe_key = tostring(ws and (ws.name or ws.id) or "")

            -- Get the specific array of widths for this workspace
            local current_array = workspace_widths[safe_key] or default_widths

            cycle_idx = (cycle_idx % #current_array) + 1

            -- Dispatch the layout resize
            hl.dispatch(hl.dsp.layout("colresize " .. current_array[cycle_idx]))
          end)

          scrolling_binds("SUPER + C", function()
            local prev = hl.get_config("scrolling.focus_fit_method")

            hl.config({ scrolling = { focus_fit_method = 0 } })
            hl.dispatch(hl.dsp.layout("center"))
            hl.config({ scrolling = { focus_fit_method = prev } })
          end)



          --     █         ▀             █  ▀█                █       ▀             █
          -- ▄▀▀▀█ █   █  ▀█   █▀▀▀▄ ▄▀▀▀█   █   ▄▀▀▀▄        █▀▀▀▄  ▀█   █▀▀▀▄ ▄▀▀▀█ ▄▀▀▀▀
          -- █   █ █ █ █   █   █   █ █   █   █   █▀▀▀▀        █   █   █   █   █ █   █  ▀▀▀▄
          -- ▀▄▄▄█ ▀▄█▄▀  ▄█▄  █   █ ▀▄▄▄█   ▀▄▄ ▀▄▄▄▄        █▄▄▄▀  ▄█▄  █   █ ▀▄▄▄█ ▄▄▄▄▀

          local function dwindle_only(fn)
            return function()
              local workspace = hl.get_active_workspace()
              if workspace and workspace.tiled_layout == "dwindle" then
                fn()
              end
            end
          end

          local function dwindle_binds(key, action)
            local fn = type(action) == "function" and action or function() hl.dispatch(action) end
            hl.bind(key, dwindle_only(fn))
          end

          dwindle_binds("SUPER + C", hl.dsp.layout("togglesplit"))
          dwindle_binds("SUPER + F", hl.dsp.layout("swapsplit"))


          local resize_border_rule = hl.window_rule({
            name = "resize-mode-border",
            match = { focus = true },
            border_color = "rgba(f9e2afff) rgba(a6e3a1ff) rgba(89dcebff) 45deg",
            border_size = 9
          })
          resize_border_rule:set_enabled(false)

          local flash_timer = nil
          local flash_rule = nil

          local function flash_focused_window()
            -- Remove existing flash rule
            if flash_rule then
              flash_rule:set_enabled(false)
            end
            -- Create new flash rule targeting focused window
            flash_rule = hl.window_rule({
              match = { focus = true },
              border_color = "rgba(cba6f7ff) rgba(89b4faff) rgba(94e2d5ff) 120deg",
              border_size = 9
            })
            -- Cancel any pending timer
            if flash_timer then
              flash_timer:set_enabled(false)
            end
            -- Remove flash rule after 150ms
            flash_timer = hl.timer(function()
              if flash_rule then
                flash_rule:set_enabled(false)
                flash_rule = nil
              end
            end, { timeout = 150, type = "oneshot" })
          end

          -- Window movement
          local function move_window(direction)
            local ws = hl.get_active_workspace()
            if not ws then return end
            local layout = ws.tiled_layout
            if layout == "scrolling" then
              if direction == "left" then
                hl.dispatch(hl.dsp.layout("swapcol l"))
              elseif direction == "right" then
                hl.dispatch(hl.dsp.layout("swapcol r"))
              end
            else
              hl.dispatch(hl.dsp.window.swap({ direction = direction }))
            end
          end

          -- Mode management
          local function enter_nav_mode()
            flash_focused_window()
            hl.dispatch(hl.dsp.submap("nav"))
            hl.config({ decoration = { dim_inactive = true, dim_strength = 0.25 } })
          end

          local function enter_resize_mode()
            resize_border_rule:set_enabled(true)
            hl.dispatch(hl.dsp.submap("resize"))
          end

          local function exit_to_normal()
            resize_border_rule:set_enabled(false)
            hl.config({ decoration = { dim_inactive = false } })
            hl.dispatch(hl.dsp.submap("reset"))
          end

          -- Keybindings
          hl.bind("CTRL + SPACE", function() enter_nav_mode() end)

          hl.define_submap("nav", function()
            hl.bind("left", function() hl.dispatch(hl.dsp.focus({ direction = "left" })) end)
            hl.bind("right", function() hl.dispatch(hl.dsp.focus({ direction = "right" })) end)
            hl.bind("up", function() hl.dispatch(hl.dsp.focus({ direction = "up" })) end)
            hl.bind("down", function() hl.dispatch(hl.dsp.focus({ direction = "down" })) end)

            hl.bind("CTRL + left", function() move_window("left") end)
            hl.bind("CTRL + right", function() move_window("right") end)
            hl.bind("CTRL + up", function() move_window("up") end)
            hl.bind("CTRL + down", function() move_window("down") end)

            hl.bind("R", function() enter_resize_mode() end)
            hl.bind("escape", function() exit_to_normal() end)
          end)

          hl.define_submap("resize", function()
            local step = 30
            hl.bind("right", hl.dsp.window.resize({ x = step, y = 0, relative = true }), { repeating = true })
            hl.bind("left", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
            hl.bind("up", hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true })
            hl.bind("down", hl.dsp.window.resize({ x = 0, y = step, relative = true }), { repeating = true })
            hl.bind("SHIFT + right", hl.dsp.window.resize({ x = step * 2, y = 0, relative = true }), { repeating = true })
            hl.bind("SHIFT + left", hl.dsp.window.resize({ x = -step * 2, y = 0, relative = true }), { repeating = true })
            hl.bind("SHIFT + up", hl.dsp.window.resize({ x = 0, y = -step * 2, relative = true }), { repeating = true })
            hl.bind("SHIFT + down", hl.dsp.window.resize({ x = 0, y = step * 2, relative = true }), { repeating = true })
            hl.bind("escape", function()
              resize_border_rule:set_enabled(false)
              hl.dispatch(hl.dsp.submap("nav"))
            end)
          end)
        '';
    };
}
