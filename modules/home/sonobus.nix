{
  m.desktop =
    { pkgs, ... }:
    {
      hj.packages = [ pkgs.sonobus ];
      networking.firewall = {
        allowedUDPPorts = [ 45599 ]; # The specific UDP port for P2P audio (Set this in SonoBus GUI)
        allowedTCPPorts = [ 10999 ];
      };
      systemd.user.services.system-audio-capture = {
        description = "SonoBus system audio capture source";
        wantedBy = [ "default.target" ];
        after = [
          "pipewire.service"
          "pipewire-pulse.service"
          "wireplumber.service"
        ];
        requires = [ "pipewire-pulse.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.pulseaudio}/bin/pactl load-module module-remap-source source_name=system_audio_capture source_properties=device.description=System_Audio_Capture master=alsa_output.pci-0000_05_00.6.analog-stereo.monitor channels=2";
          ExecStop = "${pkgs.pulseaudio}/bin/pactl unload-module module-remap-source";
        };
      };
    };
}
