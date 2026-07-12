{
  exo.mods.desktop =
    { pkgs, self', ... }:
    {
      fonts = {
        packages =
          with pkgs;
          [
            nerd-fonts.symbols-only
            montserrat
            maple-mono.NF
          ]
          ++ (with self'.legacyPackages; [
            apple-font
            apple-font-emoji
          ]);
        enableDefaultPackages = true;
        fontDir.enable = true;
        fontconfig = {
          enable = true;
          antialias = true;
          hinting = {
            enable = true;
            style = "full";
            autohint = false;
          };
          subpixel = {
            rgba = "rgb";
            lcdfilter = "light";
          };
          defaultFonts = {
            serif = [ "SF Compact Rounded" ];
            sansSerif = [ "SF Pro Text" ];
            monospace = [ "LigaSFMono Nerd Font" ];
            emoji = [ "Apple Color Emoji" ];
          };
        };
      };
    };
  tack = {
    apple-font = {
      url = "https://s3.onelock.org/download/fonts/apple-nerd.tar.gz";
      fixed = true;
    };
    apple-font-emoji = {
      url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/macos-26-20260613-f1fc560b/AppleColorEmoji-Linux.ttf";
      fixed = true;
    };
  };
  perSystem =
    { pkgs, inputs, ... }:
    {
      legacyPackages = {
        apple-font = pkgs.stdenvNoCC.mkDerivation {
          name = "apple-font";
          src = inputs.apple-font;
          dontUnpack = true;
          dontBuild = true;
          dontConfigure = true;
          installPhase = ''
            mkdir -p $out/share/fonts/apple-nerd
            ${pkgs.rsync}/bin/rsync -r --exclude='NY/*Black*' --exclude='NY/*Heavy*' $src/ $out/share/fonts/apple-nerd
          '';
        };
        apple-font-emoji = pkgs.stdenvNoCC.mkDerivation {
          name = "apple-font-emoji";
          src = inputs.apple-font-emoji;
          dontUnpack = true;
          dontBuild = true;
          dontConfigure = true;
          installPhase = ''
            install -D -m644 $src $out/share/fonts/truetype/AppleColorEmoji-Linux.ttf
          '';
        };
      };
    };
}
