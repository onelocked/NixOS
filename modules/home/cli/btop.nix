{ inputs, ... }:
{
  m.btop =
    { pkgs, config, ... }:
    {
      hj.packages = [
        (inputs.wrappers.wrappers.btop.wrap {
          inherit pkgs;
          inherit (config.custom.programs.btop) settings;
          inherit (config.custom.programs.btop) themes;
        })
      ];
      custom.programs.btop = {
        settings = {
          color_theme = "oneshill";
          vim_keys = true;
          rounded_corners = true;
          proc_tree = false;
          show_gpu_info = "on";
          show_uptime = true;
          show_coretemp = true;
          theme_background = false;
          cpu_single_graph = true;
          show_disks = true;
          show_swap = true;
          swap_disk = false;
          use_fstab = false;
          only_physical = false;
          shown_boxes = "cpu mem net proc gpu0";
          gpu_mirror_graph = false;
        };
        themes = {
          oneshill = # bash
            ''
              theme[main_bg]="#131316"
              theme[main_fg]="#e5e1e6"
              theme[title]="#c5c0ff"
              theme[hi_fg]="#ebb9d0"
              theme[selected_bg]="#353438"
              theme[selected_fg]="#e5e1e6"
              theme[inactive_fg]="#c8c5d0"
              theme[proc_misc]="#c7c4dc"
              theme[cpu_box]="#928f99"
              theme[mem_box]="#928f99"
              theme[net_box]="#928f99"
              theme[proc_box]="#928f99"
              theme[div_line]="#47464f"
              theme[temp_start]="#c5c0ff"
              theme[temp_mid]="#c7c4dc"
              theme[temp_end]="#ebb9d0"
              theme[cpu_start]="#c5c0ff"
              theme[cpu_mid]="#c7c4dc"
              theme[cpu_end]="#ebb9d0"
              theme[free_start]="#c5c0ff"
              theme[free_mid]="#c7c4dc"
              theme[free_end]="#ebb9d0"
              theme[cached_start]="#c5c0ff"
              theme[cached_mid]="#c7c4dc"
              theme[cached_end]="#ebb9d0"
              theme[available_start]="#c5c0ff"
              theme[available_mid]="#c7c4dc"
              theme[available_end]="#ebb9d0"
              theme[used_start]="#c5c0ff"
              theme[used_mid]="#c7c4dc"
              theme[used_end]="#ebb9d0"
              theme[download_start]="#c5c0ff"
              theme[download_mid]="#c7c4dc"
              theme[download_end]="#ebb9d0"
              theme[upload_start]="#c5c0ff"
              theme[upload_mid]="#c7c4dc"
              theme[upload_end]="#ebb9d0"
            '';
        };
      };
    };
  m.default =
    { lib, ... }:
    {
      options.custom.programs.btop =
        let
          inherit (lib) types;
        in
        {
          settings = lib.mkOption {
            type = types.attrsOf (
              types.oneOf [
                types.bool
                types.float
                types.int
                types.str
              ]
            );
            default = "";
            description = "btop settings";
          };
          themes = lib.mkOption {
            type = types.lazyAttrsOf (types.either types.path types.lines);
            default = "";
            description = "btop theme";
          };
        };
    };
}
