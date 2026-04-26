{ self, ... }:
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
            mkOpener = pkg: desc: [
              {
                run = "${getExe pkg} %s";
                inherit desc;
              }
            ];
          in
          with pkgs;
          {
            setwallpaper = [
              {
                run = "${getExe awww} img %s --transition-duration 2 --transition-fps 60 --transition-bezier .43,1.19,1,.4 --transition-type any";
                desc = "Set Wallpaper";
              }
            ];
            loupe = mkOpener self.packages.${pkgs.stdenv.hostPlatform.system}.loupe "Loupe";
            nomacs = mkOpener nomacs "Image Editor";
            video-trimmer = mkOpener video-trimmer "Video Trimmer";
          };
      };
    };
  perSystem =
    { pkgs, ... }:
    {
      packages.loupe = pkgs.loupe.overrideAttrs (oldAttrs: {
        doCheck = false;
        postPatch =
          (oldAttrs.postPatch or "")
          # nix
          + ''
            substituteInPlace src/widgets/edit/crop.ui \
              --replace-fail '"yes">5:4</attribute>' '"yes">43:18</attribute>' \
              --replace-fail '"yes">4:3</attribute>'  '"yes">32:9</attribute>' \
              --replace-fail '"yes">_5:4</property>'  '"yes">_43:18</property>' \
              --replace-fail '"yes">_4:3</property>'  '"yes">_32:9</property>'

            substituteInPlace src/widgets/edit/crop_selection.rs \
              --replace-fail 'Self::R5to4 => Some((5, 4)),'  'Self::R5to4 => Some((43, 18)),' \
              --replace-fail 'Self::R4to3 => Some((4, 3)),'  'Self::R4to3 => Some((32, 9)),'
          '';
      });
    };
}
