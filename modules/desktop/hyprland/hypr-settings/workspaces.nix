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

        hl.workspace_rule {
            workspace = "1",
            layout_opts = {
                explicit_column_widths = "0.333,0.5,0.667,0.7162,0.92"
            }
        }

        hl.workspace_rule {
            workspace = "2",
            layout_opts = {
                explicit_column_widths = "0.333,0.5,0.7162"
            }
        }

        hl.workspace_rule {
            workspace = "3",
            layout_opts = {
                explicit_column_widths = "0.333,0.5,0.7162"
            }
        }

        hl.workspace_rule {
            workspace = "4",
            layout_opts = {
                explicit_column_widths = "0.5,0.71"
            }
        }
      '';
  };
}
