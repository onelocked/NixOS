{
  exo.mods.desktop =
    {
      lib,
      hostName,
      theme,
      ...
    }:
    {
      forte.hyprland.lua.settings = # lua
        ''

          hl.on("hyprland.start", function()
            hl.dispatch(hl.dsp.exec_cmd("sleep 2 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.6"))
          end)

          --                                      ▀█
          -- ▄▀▀▀█ ▄▀▀▀▄ █▀▀▀▄ ▄▀▀▀▄ █▄▀▀▀  ▀▀▀▄   █
          -- █   █ █▀▀▀▀ █   █ █▀▀▀▀ █     ▄▀▀▀█   █
          -- ▀▄▄▄█ ▀▄▄▄▄ █   █ ▀▄▄▄▄ █     ▀▄▄▄█   ▀▄▄
          --  ▄▄▄▀

          hl.config({
            general = {
              gaps_in           = 8,
              gaps_out = 17,
              no_focus_fallback = true,

              border_size       = 1,

              col         = {
                inactive_border = { colors = { "${if theme == "dark" then "#313245" else "#8a8078"}" } },
                active_border   = { colors = { "${if theme == "dark" then "#7d75c0" else "#4b3a2b"}" } },
              },

              resize_on_border  = false,

              -- see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
              allow_tearing     = false,

              layout            = "scrolling",
            },

            decoration = {
              border_part_of_window = false,
              rounding              = 0,
              rounding_power        = 0,

              active_opacity        = ${if theme == "dark" then "0.93" else "0.88"},
              inactive_opacity      = ${if theme == "dark" then "0.89" else "0.83"},

              blur                  = {
                enabled  = true,
                xray     = true,
                size     = 8,
                passes   = 3,
                vibrancy = 0.1696,
              },

              shadow = {
                enabled      = ${if theme == "dark" then "false" else "true"},
                range        = 15,
                render_power = 30,
                color        = "#59311fCC",
                offset       = { 5, 5 }
              },
            },

            animations = {
              enabled = true,
            },


            --         ▀
            -- █▀█▀▄  ▀█   ▄▀▀▀▀ ▄▀▀▀▄
            -- █ █ █   █    ▀▀▀▄ █
            -- █ █ █  ▄█▄  ▄▄▄▄▀ ▀▄▄▄▀

            misc = {
              force_default_wallpaper    = 0,
              disable_hyprland_logo      = true,
              middle_click_paste         = false,
              enable_swallow             = true,
              on_focus_under_fullscreen  = 1,
              initial_workspace_tracking = true,
              disable_autoreload         = false,
              layers_hog_keyboard_focus  = false,
              focus_on_activate          = true,
              vrr = 0,
            },

            binds = {
              hide_special_on_workspace_change = true,
            },

            render = {
              direct_scanout = 1,
              new_render_scheduling = true,
              use_fp16 = 1,
              cm_enabled = 0;
              cm_auto_hdr = 0;
            },

            --  ▀                       █
            -- ▀█   █▀▀▀▄ █▀▀▀▄ █   █  ▀█▀
            --  █   █   █ █   █ █   █   █
            -- ▄█▄  █   █ █▄▄▄▀ ▀▄▄▄█   ▀▄▄
            --            █
            layout = {
              single_window_aspect_ratio = { 16, 9 },
            },

            input = {
              kb_layout           = "us",
              kb_variant          = "",
              kb_model            = "",
              kb_options          = "",
              kb_rules            = "",
              repeat_rate         = 40,
              repeat_delay        = 370,
              float_switch_override_focus = 0,

              focus_on_close      = 2,

              follow_mouse        = 2,
              mouse_refocus       = false,

              sensitivity         = 0, -- -1.0 - 1.0, 0 means no modification.

              virtualkeyboard     = {
                release_pressed_on_close = false,
              },
            },
            cursor = {
              -- Prevents the mouse from snapping to the center when changing focus
              no_warps = true,
              use_cpu_buffer = 2,
              no_hardware_cursors = 0,
            },
            ecosystem = {
              no_update_news = true,
              no_donation_nag = true,
            },

           -- ▀█                             █
           --  █    ▀▀▀▄ █   █ ▄▀▀▀▄ █   █  ▀█▀  ▄▀▀▀▀
           --  █   ▄▀▀▀█ █   █ █   █ █   █   █    ▀▀▀▄
           --  ▀▄▄ ▀▄▄▄█ ▀▄▄▄█ ▀▄▄▄▀ ▀▄▄▄█   ▀▄▄ ▄▄▄▄▀
           --             ▄▄▄▀

            dwindle = {
              force_split                  = 2,
              preserve_split               = true,
              smart_split                  = false,
              smart_resizing               = false,
              permanent_direction_override = false,
              special_scale_factor         = 1,
              split_width_multiplier       = 2,
              use_active_for_splits        = true,
              default_split_ratio          = 1,
              split_bias                   = 1,
              precise_mouse_move           = false,
            },

            scrolling = {
              direction = "right",
              fullscreen_on_one_column = false,
              column_width = 0.711,
              wrap_swapcol = false,
              wrap_focus = false,
            },
          })

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
            return ws.name == "dev0" or ws.name == "dev1"
          end

          -- scroll behave like dwindle for first 4 windows
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
          -- lib
          function is_file_exists(name)
             local f = io.open(name, "r")
             if f ~= nil then
                io.close(f)
                return true
             else
                return false
             end
          end

          --                    █
          -- █   █ ▄▀▀▀▄ █▄▀▀▀  █ ▄▀ ▄▀▀▀▀ █▀▀▀▄  ▀▀▀▄ ▄▀▀▀▄ ▄▀▀▀▄ ▄▀▀▀▀
          -- █ █ █ █   █ █      ██    ▀▀▀▄ █   █ ▄▀▀▀█ █     █▀▀▀▀  ▀▀▀▄
          -- ▀▄█▄▀ ▀▄▄▄▀ █      █ ▀▄ ▄▄▄▄▀ █▄▄▄▀ ▀▄▄▄█ ▀▄▄▄▀ ▀▄▄▄▄ ▄▄▄▄▀
          --                               █

          -- named workspaces
          for index, name in ipairs({ "web", "dev0", "dev1", "chat", "media"${
            lib.optionalString (hostName == "gaming-pc") '', "games"''
          } }) do
            hl.workspace_rule({ workspace = tostring(index), default_name = name, persistent = true })
          end
        '';
    };
}
