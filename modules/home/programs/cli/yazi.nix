{ inputs, ... }:
{
  flake.modules.homeManager.cli =
    {
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) getExe;
    in
    {
      nix.settings = {
        extra-substituters = [ "https://yazi.cachix.org" ];
        extra-trusted-substituters = [ "https://yazi.cachix.org" ];
        extra-trusted-public-keys = [ "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k=" ];
      };
      programs.yazi = {
        enable = true;
        enableBashIntegration = true;
        enableNushellIntegration = true;
        package = inputs.yazi.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
            suppress_preload = false;
          };
          plugin = {
            prepend_preloaders = [
              {
                mime = "image/jxl";
                run = "image";
              }
            ];
            preloaders = [
              {
                mime = "image/{avif,heic,svg+xml}";
                run = "${getExe pkgs.imagemagick}";
              }
              {
                mime = "image/*";
                run = "image";
              }
            ];
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
              # or 0 3 4
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
            image_delay = 90;
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
        initLua = ''
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
