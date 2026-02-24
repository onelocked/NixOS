{
  flake.homeModules = {

    obs-studio = {
      programs.obs-with-plugins = {
        enable = true;
        startService = true;
      };
    };

    default =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let
        cfg = config.programs.obs-with-plugins;

        obs-wrapped = pkgs.wrapOBS {
          plugins = with pkgs.obs-studio-plugins; [
            distroav
            wlrobs
            obs-vaapi
            obs-vkcapture
            obs-pipewire-audio-capture
          ];
        };
        inherit (lib)
          mkEnableOption
          mkOption
          mkIf
          getExe
          types
          ;
      in
      {
        options.programs.obs-with-plugins = {
          enable = mkEnableOption "OBS Studio with pre-configured plugins";

          startService = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to enable the obs-startup systemd service.";
          };
        };

        config = mkIf cfg.enable {
          home.packages = [ obs-wrapped ];

          systemd.user = mkIf cfg.startService {
            tmpfiles.rules = [
              "R %h/.config/obs-studio/.sentinel"
            ];

            services."obs-startup" = {
              Unit = {
                Description = "OBS Startup";
                After = [ "quickshell.service" ];
              };

              Service = {
                Type = "simple";
                ExecStart = getExe obs-wrapped;
              };

              Install = {
                WantedBy = [ "quickshell.service" ];
              };
            };
          };
        };
      };
  };
}
