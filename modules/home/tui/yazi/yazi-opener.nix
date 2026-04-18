{
  m.yazi =
    { pkgs, lib, ... }:
    {
      custom.programs.yazi.settings = {
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
        opener =
          let
            inherit (lib) getExe;
          in
          with pkgs;
          {
            setwallpaper = [
              {
                run = "${getExe awww} img %s --transition-duration 2 --transition-fps 60 --transition-bezier .43,1.19,1,.4 --transition-type any";
                desc = "Set Wallpaper";
              }
            ];
            loupe = [
              {
                run = "${getExe loupe} %s";
                desc = "Loupe";
              }
            ];
            nomacs = [
              {
                run = "${getExe nomacs} %s";
                desc = "Image Editor";
              }
            ];
            video-trimmer = [
              {
                run = "${getExe video-trimmer} %s";
                desc = "Video Trimmer";
              }
            ];
          };
      };
    };
}
