{
  m.yazi =
    {
      pkgs,
      lib,
      envoy,
      ...
    }:
    {
      forte.yazi = {
        plugins =
          let
            mkSpotPlugin =
              name:
              pkgs.yaziPlugins.mkYaziPlugin {
                pname = name;
                version = "1.0";
                src = lib.cleanSourceWith {
                  src = envoy.yazi-plugins.src + "/${name}.yazi";
                  filter = name: _type: baseNameOf name == "main.lua";
                };
              };
          in
          lib.genAttrs [ "spot" "spot-image" "spot-video" "spot-audio" ] mkSpotPlugin;
        settings.plugins = {
          prepend_spotters =
            let
              byMime = mime: run: { inherit mime run; };
              byUrl = url: run: { inherit url run; };
            in
            [
              (byMime "audio/*" "spot")
              (byMime "image/*" "spot-image")
              (byUrl "video/*" "spot-video")
              (byMime "audio/mpegurl" "code")
              (byUrl "audio/*" "spot-audio")
              (byUrl "*/" "spot")
              (byUrl "*" "spot")
            ];
        };
        initLua = # lua
          ''
            require('spot'):setup {
              metadata_section = {
                enable = true,
                hash_cmd = 'xxhsum', -- other hashing commands may be slower
                hash_filesize_limit = 150, -- in MB, set 0 to disable
                relative_time = true, -- 2026-01-01 or n days ago
                time_format = '%Y-%m-%d %H:%M', -- https://www.man7.org/linux/man-pages/man3/strftime.3.html
                show_compression = true, ---@type boolean
              },
              plugins_section = {
                enable = false,
              },
              style = {
                section = 'green',
                key = 'reset',
                value = 'blue',
                selected = 'blue',
                colorize_metadata = true,
                height = 20,
                width = 60,
                key_length = 15,
              },
            }
          '';
      };
    };
  envoy = {
    yazi-plugins = {
      github = "AminurAlam/yazi-plugins";
      locked = true;
    };
  };
}
