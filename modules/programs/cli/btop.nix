{
  m.btop =
    { scheme, ... }:
    {
      systemd.tmpfiles.rules = [
        "z /sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj 0444 root root - -"
      ];
      forte.xdg.desktopEntries."btop".noDisplay = true;
      forte.btop = {
        enable = true;
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
          oneshill =
            with scheme.withHashtag; # bash
            ''
              theme[main_bg]="${base00}"         # #131316
              theme[main_fg]="${base07}"         # #f0f2fa
              theme[title]="${base0F}"           # #c5c0ff
              theme[hi_fg]="${base0E}"           # #c8b0e8
              theme[selected_bg]="${base02}"     # #2e2438
              theme[selected_fg]="${base07}"     # #f0f2fa
              theme[inactive_fg]="${base05}"     # #cfd3e7
              theme[proc_misc]="${base06}"       # #e4e8f5
              theme[cpu_box]="${base04}"         # #8c92aa
              theme[mem_box]="${base04}"         # #8c92aa
              theme[net_box]="${base04}"         # #8c92aa
              theme[proc_box]="${base04}"        # #8c92aa
              theme[div_line]="${base03}"        # #3d3050
              theme[temp_start]="${base0F}"      # #c5c0ff
              theme[temp_mid]="${base06}"        # #e4e8f5
              theme[temp_end]="${base0E}"        # #c8b0e8
              theme[cpu_start]="${base0F}"       # #c5c0ff
              theme[cpu_mid]="${base06}"         # #e4e8f5
              theme[cpu_end]="${base0E}"         # #c8b0e8
              theme[free_start]="${base0F}"      # #c5c0ff
              theme[free_mid]="${base06}"        # #e4e8f5
              theme[free_end]="${base0E}"        # #c8b0e8
              theme[cached_start]="${base0F}"    # #c5c0ff
              theme[cached_mid]="${base06}"      # #e4e8f5
              theme[cached_end]="${base0E}"      # #c8b0e8
              theme[available_start]="${base0F}" # #c5c0ff
              theme[available_mid]="${base06}"   # #e4e8f5
              theme[available_end]="${base0E}"   # #c8b0e8
              theme[used_start]="${base0F}"      # #c5c0ff
              theme[used_mid]="${base06}"        # #e4e8f5
              theme[used_end]="${base0E}"        # #c8b0e8
              theme[download_start]="${base0F}"  # #c5c0ff
              theme[download_mid]="${base06}"    # #e4e8f5
              theme[download_end]="${base0E}"    # #c8b0e8
              theme[upload_start]="${base0F}"    # #c5c0ff
              theme[upload_mid]="${base06}"      # #e4e8f5
              theme[upload_end]="${base0E}"      # #c8b0e8
            '';
        };
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.btop = pkgs.btop-rocm.overrideAttrs {
        patches = [
          (pkgs.fetchpatch2 {
            name = "normalize_processes";
            url = "https://raw.githubusercontent.com/NotAShelf/nyxexprs/refs/heads/main/pkgs/btop/patches/normalize_processes.patch";
            hash = "sha256-dh3TTb0Ix983W50inTzGflQ7mpBELaKReBUmzjBixTo=";
          })
        ];
      };
    };
  m.default =
    {
      lib,
      pkgs,
      birdee,
      config,
      self',
      ...
    }:
    let
      cfg = config.forte.btop;
    in
    {
      config = lib.mkIf (cfg.enable) {
        hj.packages = [ cfg.package ];
      };
      options.forte.btop = {
        enable = lib.mkEnableOption "zen-browser";

        settings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
        };

        themes = lib.mkOption {
          type = lib.types.attrs;
          default = { };
        };

        package = lib.mkOption {
          default = birdee.wrappers.btop.wrap {
            inherit pkgs;
            package = self'.packages.btop;
            inherit (cfg) settings themes;
          };
        };
      };
    };
}
