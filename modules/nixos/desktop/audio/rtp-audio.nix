{
  m.rtp-audio = {
    networking.firewall.allowedUDPPorts = [ 45599 ]; # The specific UDP port for P2P audio (Set this in SonoBus GUI)
    services.pipewire = {
      extraConfig.pipewire."99-rtp-audio" = {
        "context.modules" = [
          {
            name = "libpipewire-module-rtp-sink";
            args = {
              "destination.ip" = "192.168.1.209";
              "destination.port" = 45599;
              "sess.latency.msec" = 50;
              "audio.channels" = 2;
              "audio.format" = "S16BE";
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
}
