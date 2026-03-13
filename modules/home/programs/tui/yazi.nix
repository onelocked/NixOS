{
  flake.modules.homeManager.yazi =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.yazi =
        let
          inherit (lib) getExe;
        in
        {
          enable = true;
          shellWrapperName = "y";
          enableBashIntegration = true;
          enableNushellIntegration = true;
          enableFishIntegration = true;
          package = pkgs.yazi;
          plugins =
            let
              pluginNames = [
                "starship"
                "full-border"
                "no-status"
                "ouch"
                "lazygit"
              ];
            in
            builtins.listToAttrs (
              map (name: {
                inherit name;
                value = pkgs.yaziPlugins.${name};
              }) pluginNames
            );
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
            open = {
              prepend_rules = [
                {
                  mime = "image/*"; # Apply this to all image types
                  use = [
                    "open"
                    "setwallpaper"
                    "loupe"
                    "nomacs"
                  ];
                }
                {
                  mime = "video/*"; # Apply this to all video types
                  use = [
                    "open"
                    "video-trimmer"
                  ];
                }
              ];
            };
            opener = {
              setwallpaper = [
                {
                  run = "qs ipc call wallpaper set %s all";
                  desc = "Set Wallpaper";
                }
              ];
              loupe = [
                {
                  run = "${getExe pkgs.loupe} %s";
                  desc = "Loupe";
                }
              ];
              nomacs = [
                {
                  run = "${getExe pkgs.nomacs} %s";
                  desc = "Image Editor";
                }
              ];
              video-trimmer = [
                {
                  run = "${getExe pkgs.video-trimmer} %s";
                  desc = "Video Trimmer";
                }
              ];
            };
          };

          keymap = {
            mgr.prepend_keymap = [
              {
                on = [
                  "l"
                  "g"
                ];
                run = "plugin lazygit";
                desc = "run lazygit";
              }
              {
                on = [
                  "g"
                  "r"
                ];
                run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
                desc = "git root";
              }
              {
                on = [
                  "g"
                  "s"
                ];
                run = "shell -- ya emit cd /mnt/s3";
                desc = "Go to S3";
              }

              {
                on = [
                  "b"
                  "y"
                ];
                run = [
                  ''shell -- for path in %s; do echo "file://$path"; done | wl-copy -t text/uri-list''
                ];
                desc = "copy to clipboard";
              }
            ];
          };
          initLua = # lua
            ''
              require("starship"):setup({
                  hide_flags = false, -- Default: false
                  flags_after_prompt = true, -- Default: true
                  config_file = "~/.config/starship.toml", -- Default: nil
              })
              require("no-status"):setup()
              require("full-border"):setup {
              	type = ui.Border.ROUNDED,
              }
            '';
        };
    };
}
