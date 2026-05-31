{
  m.yazi =
    {
      lib,
      self',
      pkgs,
      ...
    }:
    let
      run = "${pkgs.nix}/bin/nix run";
    in
    {
      forte.yazi.settings = {
        open = {
          prepend_rules = [
            {
              mime = "image/*"; # Apply this to all image types
              use = [
                "open"
                "images"
              ];
            }
            {
              mime = "video/*"; # Apply this to all video types
              use = [
                "open"
                "videos"
              ];
            }
          ];
        };
        opener = {
          images = [
            {
              run = "${pkgs.awww}/bin/awww img %s --transition-duration 2 --transition-fps 60 --transition-bezier .43,1.19,1,.4 --transition-type any";
              desc = "Set Wallpaper";
            }
            {
              run = "${run} nixpkgs#gimp %s";
              desc = "Edit with Gimp";
            }
            {
              run = "${lib.getExe self'.packages.loupe} %s";
              desc = "Open with Loupe";
            }
          ];
          videos = [
            {
              run = "${run} nixpkgs#video-trimmer %s";
              desc = "Videos Trimmer";
            }
          ];
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
