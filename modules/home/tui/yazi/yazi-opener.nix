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
            mkOpener = pkg: desc: [ { run = "${getExe pkg} %s"; inherit desc; } ];
          in
          with pkgs;
          {
            setwallpaper = [
              {
                run = "${getExe awww} img %s --transition-duration 2 --transition-fps 60 --transition-bezier .43,1.19,1,.4 --transition-type any";
                desc = "Set Wallpaper";
              }
            ];
            loupe = mkOpener loupe "Loupe";
            nomacs = mkOpener nomacs "Image Editor";
            video-trimmer = mkOpener video-trimmer "Video Trimmer";
          };
      };
    };
}
