{
  flake.modules.homeManager.yazi =
    { config, ... }:
    {
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";
        enableNushellIntegration = config.programs.nushell.enable or false;
        enableFishIntegration = config.programs.fish.enable or false;
        settings = {
          tasks = {
            micro_workers = 10;
            macro_workers = 10;
            bizarre_retry = 3;
            image_alloc = 536870912;
            image_bound = [
              0
              0
            ];
            suppress_preload = true;
          };
          mgr = {
            sort_by = "natural";
            sort_sensitive = false;
            show_hidden = false;
            show_symlink = true;
            sort_reverse = false;
            sort_dir_first = true;
            linemode = "size";
            sort_translit = false;
            scrolloff = 5;
            title_format = "Yazi: {cwd}";
            ratio = [
              2
              3
              3
            ];
          };
          preview = {
            wrap = "no";
            tab_size = 2;
            image_filter = "triangle"; # from fast to slow but high quality: nearest, triangle, catmull-rom, lanczos3
            cache_dir = "";
            image_delay = 0;
            max_width = 1200; # maybe 1000
            max_height = 1200; # maybe 1000
            image_quality = 60;
            sixel_fraction = 15;
            ueberzug_scale = 1;
            ueberzug_offset = [
              0
              0
              0
              0
            ];
          };
        };
      };
    };
}
