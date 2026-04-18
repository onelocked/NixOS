{
  m.obs-studio =
    { pkgs, lib, ... }:
    let
      obs-wrapped = (
        pkgs.wrapOBS {
          plugins = with pkgs.obs-studio-plugins; [
            distroav
            obs-pipewire-audio-capture
          ];
        }
      );
    in
    {
      hj = {
        packages = [ obs-wrapped ];
        systemd.services."obs-startup" = {
          description = "OBS Auto Startup";

          after = [ "graphical-session.target" ];
          wants = [ "graphical-session.target" ];

          wantedBy = [ "graphical-session.target" ];

          serviceConfig = {
            Type = "simple";
            ExecStart = lib.getExe obs-wrapped;
          };
        };
      };
      systemd.user = {
        tmpfiles.rules = [ "R %h/.config/obs-studio/.sentinel" ];
      };

      networking.firewall = {
        allowedTCPPortRanges = [
          {
            from = 5961;
            to = 5970;
          } # NDI TCP
          {
            from = 6960;
            to = 6970;
          }
          {
            from = 7960;
            to = 7970;
          }
        ];
        allowedUDPPortRanges = [
          {
            from = 5960;
            to = 5970;
          } # NDI UDP
          {
            from = 6960;
            to = 6970;
          }
          {
            from = 7960;
            to = 7970;
          }
        ];
        allowedUDPPorts = [ 5353 ]; # mDNS for NDI source discovery
      };
    };
}
