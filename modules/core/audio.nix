{
  flake.modules.nixos.core =
    { ... }:
    {
      security.rtkit.enable = true;

      services = {
        pulseaudio.enable = false;
        pipewire = {
          enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
          pulse.enable = true;
          wireplumber = {
            enable = true;
            # configPackages = [
            #   (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/11-bluetooth-policy.conf" ''
            #     bluetooth.autoswitch-to-headset-profile = false
            #   '')
            # ];
          };

          # extraConfig.pipewire."91-null-sinks" = {
          #   "context.objects" = [
          #     {
          #       # A default dummy driver. This handles nodes marked with the "node.always-driver"
          #       # property when no other driver is currently active. JACK clients need this.
          #       factory = "spa-node-factory";
          #       args = {
          #         "factory.name" = "support.node.driver";
          #         "node.name" = "Dummy-Driver";
          #         "priority.driver" = 8000;
          #       };
          #     }
          #     {
          #       factory = "adapter";
          #       args = {
          #         "factory.name" = "support.null-audio-sink";
          #         "node.name" = "Microphone-Proxy";
          #         "node.description" = "Microphone";
          #         "media.class" = "Audio/Source/Virtual";
          #         "audio.position" = "FL,FR";
          #       };
          #     }
          #     {
          #       factory = "adapter";
          #       args = {
          #         "factory.name" = "support.null-audio-sink";
          #         "node.name" = "Main-Output-Proxy";
          #         "node.description" = "Main Output";
          #         "media.class" = "Audio/Sink";
          #         "audio.position" = "FL,FR";
          #       };
          #     }
          #   ];
          # };
        };
      };
    };
}
