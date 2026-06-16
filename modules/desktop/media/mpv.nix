{
  exo.mods.desktop =
    { config, ... }:
    {
      forte.mpv = {
        enable = true;
        with-wlpaste = true;
        conf = # ini
          ''
            osd-duration=500
            osc=no
            video-sync=display-resample
            interpolation=yes
            volume=80
            ao=pipewire
            audio-buffer=0.1
            audio-file-auto=fuzzy
            sub-auto=fuzzy
            sub-font="Apple Color Emoji"
            gpu-context=auto
            hwdec=auto-copy
            profile=gpu-hq
            vo=gpu-next
            gpu-api=auto
            deband=yes
            wayland-edge-pixels-pointer=0
            wayland-edge-pixels-touch=0
            screenshot-format=webp
            screenshot-webp-lossless=yes
            screenshot-directory=${config.hj.directory}/Pictures/Screenshots/mpv
            screenshot-sw=yes
            input-default-bindings=yes
            ytdl-format=bestvideo[height<=2160]+bestaudio/best[height<=2160]
            loop-file=inf
            autofit=x1355
          '';
        image-conf = # ini
          ''
            image-display-duration=inf
            loop-file=inf
            autofit=x1200
            osd-level=0
            window-dragging=no
            osc=no
            gpu-context=auto
            hwdec=auto-copy
            profile=gpu-hq
            vo=gpu-next
            gpu-api=auto
          '';
      };
    };
  exo.skeleton =
    {
      lib,
      pkgs,
      birdee,
      config,
      self',
      ...
    }:
    let
      cfg = config.forte.mpv;
    in
    {
      config = lib.mkIf cfg.enable {
        hj.packages = [
          cfg.package
          cfg.image-viewer
        ];
        forte.otter-launcher.modules = lib.mkIf cfg.with-wlpaste [
          {
            description = "video";
            prefix = "mpv";
            cmd = "app2unit -- ${cfg.mpv-wlpaste}/bin/mpv-wlpaste";
          }
        ];
        forte.hyprland.lua.window-rules = # lua
          ''
            hl.window_rule({
              name         = "mpv",
              match        = { class = "mpv" },
              center       = true,
              float        = true,
              opacity      = "1 override",
            })
          '';
        forte.xdg.desktopEntries."umpv".noDisplay = true;
        forte.xdg.desktopEntries."mpvi" = {
          name = "MPV Image Viewer";
          exec = "${cfg.image-viewer}/bin/mpv %U";
          noDisplay = true;
          icon = "mpv";
          mimeType = [
            "image/png"
            "image/jpeg"
            "image/jpg"
            "image/webp"
            "image/gif"
          ];
        };
      };

      options.forte.mpv = {
        enable = lib.mkEnableOption "mpv";
        with-wlpaste = lib.mkEnableOption "mpv-wl-paste";

        conf = lib.mkOption {
          default = "";
          type = lib.types.lines;
        };

        image-conf = lib.mkOption {
          default = "";
          type = lib.types.lines;
        };

        image-input = lib.mkOption {
          type = lib.types.lines;
          default = # bash
            ''
              MBTN_LEFT script-binding positioning/drag-to-pan
              WHEEL_UP      add video-zoom  0.1
              WHEEL_DOWN    add video-zoom -0.1

              k             add video-pan-y  0.01
              j             add video-pan-y -0.01
              h             add video-pan-x  0.01
              l             add video-pan-x -0.01

              Ctrl+r         set video-zoom 0 ; set video-pan-x 0 ; set video-pan-y 0
            '';
        };

        input = lib.mkOption {
          default = # bash
            ''
              MBTN_LEFT cycle pause
              WHEEL_DOWN add volume -1
              WHEEL_UP add volume 1
              S screenshot video

              h no-osd seek -5 exact
              LEFT no-osd seek -5 exact
              l no-osd seek 5 exact
              RIGHT no-osd seek 5 exact
              j seek -30
              DOWN seek -30
              k seek 30
              UP seek 30

              H no-osd seek -1 exact
              Shift+LEFT no-osd seek -1 exact
              L no-osd seek 1 exact
              Shift+RIGHT no-osd seek 1 exact
              J seek -300
              Shift+DOWN seek -300
              K seek 300
              Shift+UP seek 300

              Ctrl+LEFT no-osd sub-seek -1
              Ctrl+h no-osd sub-seek -1
              Ctrl+RIGHT no-osd sub-seek 1
              Ctrl+l no-osd sub-seek 1
              Ctrl+DOWN add chapter -1
              Ctrl+j add chapter -1
              Ctrl+UP add chapter 1
              Ctrl+k add chapter 1

              Alt+LEFT frame-back-step
              Alt+h frame-back-step
              Alt+RIGHT frame-step
              Alt+l frame-step

              PGUP add chapter 1
              PGDWN add chapter -1

              u revert-seek

              Ctrl++ add sub-scale 0.1
              Ctrl+- add sub-scale -0.1
              Ctrl+0 set sub-scale 0

              q quit
              Q quit-watch-later
              q {encode} quit 4
              p cycle pause
              SPACE cycle pause
              f cycle fullscreen

              n playlist-next
              N playlist-prev

              o show-progress
              O script-binding stats/display-stats-toggle

              s cycle sub
              v cycle video
              a cycle audio
              c add panscan 0.1
              PLAY cycle pause
              PAUSE cycle pause
              PLAYPAUSE cycle pause
              PLAYONLY set pause no
              PAUSEONLY set pause yes
              STOP stop
            '';
          type = lib.types.lines;
        };
        image-viewer = lib.mkOption {
          type = lib.types.package;
          default = birdee.wrappers.mpv.wrap {
            inherit pkgs;
            package = pkgs.mpv;
            "mpv.conf".content = cfg.image-conf;
            "mpv.input".content = cfg.image-input;
            script.rotate-resize = {
              opts = {
                keybinds = "r";
              };
              path = self'.legacyPackages.mpv-rotate-resize;
            };
          };
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = birdee.wrappers.mpv.wrap {
            inherit pkgs;
            package = pkgs.mpv;
            script = {
              mpris.path = pkgs.mpvScripts.mpris;
              sponsorblock.path = pkgs.mpvScripts.sponsorblock;
              dynamic-crop.path = pkgs.mpvScripts.dynamic-crop;
              modernz = {
                path = pkgs.mpvScripts.modernz;
                opts.download_path = "${config.hj.directory}/Videos/mpv";
                opts.osc_on_start = "no";
                opts.osc_on_seek = "no";
                opts.showonpause = "no";
              };
              rotate-resize = {
                opts = {
                  keybinds = "r";
                };
                path = self'.legacyPackages.mpv-rotate-resize;
              };
            };
            "mpv.conf".content = cfg.conf;
            "mpv.input".content = cfg.input;
          };
        };
        mpv-wlpaste = lib.mkOption {
          type = lib.types.package;
          default = pkgs.writeShellApplication {
            name = "mpv-wlpaste";
            runtimeInputs = with pkgs; [
              cfg.package
              wl-clipboard
              uutils-coreutils-noprefix
            ];
            text = ''
              url=$(wl-paste | tr -d '[:space:]')
              if [ -z "$url" ]; then
                exit 0
              fi
              case "$url" in
                *tiktok.com*)
                  url="''${url%%\?*}"
                  ;;
              esac
              exec mpv "$url"
            '';
          };

        };
      };
    };
  perSystem =
    { pkgs, ... }:
    {
      legacyPackages.mpv-rotate-resize = pkgs.writeTextFile {
        name = "rotate-resize";
        destination = "/main.lua";
        text = # lua
          ''
            local opt = require 'mp.options'
            local script_opts = { keybinds = "r" }
            opt.read_options(script_opts, "rotate-resize")
            mp.msg.info("rotate-resize loaded")

            local max_height = 1355
            local rotations = {0, 270, 180, 90}
            local cached = {}   -- keyed by rotation value -> { w, h }
            local rot_idx = 1   -- current index into rotations

            local function precalculate(w, h)
              cached = {}
              for _, rot in ipairs(rotations) do
                local tw = (rot == 90 or rot == 270) and h or w
                local th = (rot == 90 or rot == 270) and w or h
                local scale = max_height / th
                cached[rot] = { w = math.floor(tw * scale), h = math.floor(th * scale) }
              end
              mp.msg.info(string.format("rotate-resize: cached sizes for %dx%d", w, h))
            end

            -- fires when video params become available (before file-loaded)
            mp.register_event("video-reconfig", function()
              local w = mp.get_property_number("video-params/w")
              local h = mp.get_property_number("video-params/h")
              if w and h then precalculate(w, h) end
            end)

            -- mpv resets video-rotate on each new file, so mirror that here
            mp.register_event("file-loaded", function()
              rot_idx = 1
            end)

            mp.add_key_binding(script_opts.keybinds, "rotate-resize", function()
              if not next(cached) then
                mp.msg.warn("rotate-resize: dimensions not yet available")
                return
              end

              rot_idx = (rot_idx % #rotations) + 1
              local next_val = rotations[rot_idx]

              mp.set_property("video-rotate", next_val)

              local sz = cached[next_val]
              local cmd = string.format(
                [[hyprctl --batch "dispatch hl.dsp.window.resize({ x = %d, y = %d }) ; dispatch hl.dsp.window.center()"]],
                sz.w, sz.h
              )
              mp.command_native_async({
                name = "subprocess",
                args = {"sh", "-c", cmd}
              }, function() end)
            end)
          '';
      };
    };
}
