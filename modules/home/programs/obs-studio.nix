{
  flake.homeModules = {
    obs-studio =
      { pkgs, ... }:
      {
        programs.obs-with-plugins = {
          enable = true;
          systemd = true;
          plugins = with pkgs.obs-studio-plugins; [
            distroav
            obs-pipewire-audio-capture
          ];
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
          plugins = cfg.plugins;
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
          enable = mkEnableOption "OBS Studio with configurable plugins";

          plugins = mkOption {
            type = types.listOf types.package;
            default = [ ];
            example = lib.literalExpression "with pkgs.obs-studio-plugins; [ distroav wlrobs ]";
            description = "List of OBS plugins to include in the wrapper.";
          };

          systemd = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to enable the obs-startup systemd service.";
          };
        };

        config = mkIf cfg.enable {
          home.packages = [ obs-wrapped ];

          systemd.user = mkIf cfg.systemd {
            tmpfiles.rules = [
              "R %h/.config/obs-studio/.sentinel"
            ];

            services."obs-startup" = {
              Unit = {
                Description = "OBS Startup";
                After = [ "quickshell.service" ];
                Wants = [ "quickshell.service" ];
              };

              Service = {
                Type = "simple";
                ExecStart = getExe obs-wrapped;
                Restart = "no";
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
