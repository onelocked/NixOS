{ inputs, ... }:
{
  flake-file.inputs.extra-modules.url = "github:onelocked/extra-modules";
  flake.modules.homeManager = {
    obs-studio =
      { pkgs, ... }:
      {
        imports = [ inputs.extra-modules.homeManagerModules.obs-with-plugins ];
        programs.obs-with-plugins = {
          enable = true;
          systemd = true;
          plugins = with pkgs.obs-studio-plugins; [
            distroav
            obs-pipewire-audio-capture
          ];
        };
      };
  };
  flake.modules.nixos.default = {
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
