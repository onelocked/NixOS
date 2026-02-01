{
  flake.modules.homeManager.media =
    { pkgs, lib, ... }:
    let
      obs-wrapped = (
        pkgs.wrapOBS {
          plugins = with pkgs.obs-studio-plugins; [
            distroav
            wlrobs
            obs-vaapi
            obs-vkcapture
            obs-pipewire-audio-capture
          ];
        }
      );
    in
    {
      home.packages = [ obs-wrapped ];

      systemd.user = {
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
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
            ExecStart = lib.getExe obs-wrapped;
          };

          Install = {
            WantedBy = [ "quickshell.service" ];
          };
        };
      };
    };
}
