{
  m.hyprland =
    { pkgs, config, ... }:
    let
      theme = config.forte.theme.variant;
    in
    {
      forte.hyprland.lua.settings = # lua
        ''
          ------------------
          ---- MONITORS ----
          ------------------
          hl.monitor({
            output   = "",
            mode     = "preferred",
            position = "auto",
            scale    = "auto",
          })

          ------------------
          ---- GENERAL ----
          ------------------

          hl.config({
            general = {
              gaps_in           = 10,
              gaps_out          = 50,
              no_focus_fallback = true,

              border_size       = 9,

              col               = {
                inactive_border = { colors = { "rgba(120, 120, 120, 1)" } },
                active_border   = { colors = { "rgba(30, 30, 30, 1)" } },
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

              shadow                = {
                enabled      = true,
                range        = 3,
                render_power = 5,
                color        = 0xe6222222,
                offset       = { -19, 18 }
              },
            },

            animations = {
              enabled = true,
            },


            ----------------
            ----  MISC  ----
            ----------------

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
            },

            binds = {
              hide_special_on_workspace_change = true,
            },

            render = {
              direct_scanout = 2,
              new_render_scheduling = true,
              cm_enabled = false,
            },

            ---------------
            ---- INPUT ----
            ---------------
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
              float_switch_override_focus = 0, -- NOTE:	If enabled (1 or 2), focus will change to the window under the cursor when changing from tiled-to-floating and vice versa. If 2, focus will also follow mouse on float-to-float switches.

              focus_on_close      = 0,

              follow_mouse        = 1,    -- temporary workaround switch to 2 after fix https://github.com/hyprwm/Hyprland/discussions/14285
              follow_mouse_shrink = 2000, -- remove this after fixed above
              mouse_refocus       = false,

              sensitivity         = 0, -- -1.0 - 1.0, 0 means no modification.

              virtualkeyboard     = {
                release_pressed_on_close = false,
              },
            },
            cursor = {
              -- Prevents the mouse from snapping to the center when changing focus
              no_warps = true,
              use_cpu_buffer = 0,
              no_hardware_cursors = 0,
            },
            ecosystem = {
              no_update_news = true,
              no_donation_nag = true,
            },

            ----------------
            --- Layouts  ---
            ----------------

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
              column_width = 0.7,
              wrap_swapcol = false,
              wrap_focus = false,
            },
          })

          -- autostart
          hl.on("hyprland.start", function ()
            hl.exec_cmd("${pkgs.libsecret}/bin/secret-tool lookup app keyring-init || echo 'init' | secret-tool store --label='keyring-init' app keyring-init")
          end)

          ----------------
          --Workspaces--
          ----------------
          -- ╔══════════════════════════════════════╗
          -- ║    N A M E D  W O R K S P A C E S    ║
          -- ╚══════════════════════════════════════╝
          for index, name in ipairs({ "web", "dev", "chat", "media" }) do
            hl.workspace_rule({ workspace = tostring(index), default_name = name, persistent = true })
          end

          hl.workspace_rule({ workspace = "name:dev", layout = "dwindle" })

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
        '';
    };
}
