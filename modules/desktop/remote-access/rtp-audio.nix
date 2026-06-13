{
  exo.mods.desktop =
    { lib, config, ... }:
    let
      cfg = config.forte.rtp-audio;
    in
    {
      config = lib.mkIf cfg.enable {
        services.pipewire = {
          extraConfig.pipewire."99-rtp-audio" = {
            "context.modules" = [
              {
                name = "libpipewire-module-rtp-sink";
                args = {
                  "destination.ip" = "192.168.1.209";
                  "destination.port" = 45599;
                  "sess.latency.msec" = 15;
                  "audio.channels" = 2;
                  "audio.format" = "S16BE";
                  "sess.payload" = 127;
                  "audio.rate" = 48000;
                  "always-process" = true;
                  "net.dscp" = 46;
                  "stream.props" = {
                    "node.description" = "RTP Stream";
                    "media.class" = "Audio/Sink";
                    "priority.session" = 10000;
                  };
                };
              }
            ];
          };
        };
      };
      options.forte.rtp-audio = {
        enable = lib.mkEnableOption "RTP Audio";
      };
    };
}
