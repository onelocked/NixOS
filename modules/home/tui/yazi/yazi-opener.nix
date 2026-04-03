{
  flake.modules.homeManager.yazi =
    { pkgs, lib, ... }:
    {
      programs.yazi.settings = {
        open = {
          prepend_rules = [
            {
              mime = "image/*"; # Apply this to all image types
              use = [
                "open"
                "setwallpaper"
                "loupe"
                "nomacs"
              ];
            }
            {
              mime = "video/*"; # Apply this to all video types
              use = [
                "open"
                "video-trimmer"
              ];
            }
          ];
        };
        opener = {
          setwallpaper = [
            {
              run = "awww img %s";
              desc = "Set Wallpaper";
            }
          ];
          loupe = [
            {
              run = "${lib.getExe pkgs.loupe} %s";
              desc = "Loupe";
            }
          ];
          nomacs = [
            {
              run = "${lib.getExe pkgs.nomacs} %s";
              desc = "Image Editor";
            }
          ];
          video-trimmer = [
            {
              run = "${lib.getExe pkgs.video-trimmer} %s";
              desc = "Video Trimmer";
            }
          ];
        };
      };
    };
}
