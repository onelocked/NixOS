{
  exo.mods.desktop = {
    forte.obs-studio = {
      systemd = true;
      openFirewall = true;
    };
  };
  exo.skeleton =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cfg = config.forte.obs-studio;
    in
    {

      config =
        lib.mkIf cfg.enable
        <| lib.mkMerge [
          {
            hj.packages = [ cfg.package ];
          }
          (lib.mkIf cfg.systemd {
            hj.systemd.services."obs-startup" = {
              description = "OBS Auto Startup";
              after = [ "graphical-session.target" ];
              wantedBy = [ "graphical-session.target" ];
              serviceConfig = {
                Type = "simple";
                ExecStart = lib.getExe cfg.package;
              };
            };
            systemd.user = {
              tmpfiles.rules = [ "R %h/.config/obs-studio/.sentinel" ];
            };
          })
          (lib.mkIf cfg.openFirewall {
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
          })
        ];
      options.forte.obs-studio = {
        enable = lib.mkEnableOption "obs-studio";
        package = lib.mkOption {
          type = lib.types.package;
          description = "obs-studio package to use";
          default = pkgs.wrapOBS {
            plugins = with pkgs.obs-studio-plugins; [
              distroav
              obs-pipewire-audio-capture
            ];
          };
        };
        systemd = lib.mkEnableOption "systemd startup";
        openFirewall = lib.mkEnableOption "openFirewall";
      };
    };
}
