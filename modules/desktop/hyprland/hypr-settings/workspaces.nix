{
  exo.mods.desktop = {
    forte.hyprland.lua.settings = # lua
      ''
        -- persist workspaces 1 to 5
        for i = 1, 5 do
          hl.workspace_rule({ workspace = tostring(i), persistent = true })
        end

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

        -- dynamically calculate the scrolling_width for aspect ratios of 16:9 and 21:9
        local monitor = hl.get_active_monitor()
        if not monitor then
          return
        end

        local gaps_out = 0
        local gaps_in = 0
        local border_size = 2
        hl.config({ general = { gaps_out = gaps_out, gaps_in = gaps_in, border_size = border_size } })

        local W, H = monitor.width, monitor.height
        local res = monitor.reserved or { top = 0, bottom = 0, left = 0, right = 0 }

        local usable_w = W - res.left - res.right - 2 * gaps_out
        local usable_h = H - res.top - res.bottom - 2 * gaps_out

        local inner_h = usable_h - 2 * border_size

        local function width_for(ratio, gaps_in_sides)
          return (ratio * inner_h + gaps_in_sides * gaps_in + 2 * border_size) / usable_w
        end

        local w169 = width_for(16 / 9, 2)
        local w219 = width_for(21 / 9, 2)

        hl.config({
          scrolling = {
            column_width = w169,
          },
        })

        hl.workspace_rule {
          workspace = "1",
          layout_opts = {
            explicit_column_widths = "0.333,0.5,0.667," .. w169 .. "," .. w219
          }
        }

        hl.workspace_rule {
          workspace = "2",
          layout_opts = {
            explicit_column_widths = "0.333,0.5," .. w169
          }
        }

        hl.workspace_rule {
          workspace = "3",
          layout_opts = {
            explicit_column_widths = "0.333,0.5," .. w169
          }
        }

        hl.workspace_rule {
          workspace = "4",
          layout_opts = {
            explicit_column_widths = "0.333,0.5"
          }
        }

        hl.workspace_rule {
          workspace = "5",
          layout_opts = {
            explicit_column_widths = "0.5," .. w169 .. "," .. w219
          }
        }
      '';
  };
}
