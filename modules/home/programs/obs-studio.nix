{
  flake.modules.homeManager.media =
    { pkgs, ... }:
    {
      systemd.user.tmpfiles.rules = [
        "R %h/.config/obs-studio/.sentinel"
      ];
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          distroav
          wlrobs
          obs-vaapi
          obs-vkcapture
          obs-pipewire-audio-capture
        ];
      };
    };
}
