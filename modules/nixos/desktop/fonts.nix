{
  envoy = {
    apple-font = {
      tarball = "https://s3.onelock.org/download/fonts/apple-nerd.tar.gz";
      locked = true;
    };
    apple-font-emoji = {
      url = "https://github.com/samuelngs/apple-emoji-linux/releases/latest/download/AppleColorEmoji-Linux.ttf";
      locked = true;
    };
  };
  m.desktop =
    { pkgs, envoy, ... }:
    {
      fonts = {
        packages =
          with pkgs;
          [
            nerd-fonts.symbols-only
            montserrat
            maple-mono.NF
          ]
          ++ [
            (pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
              name = envoy.apple-font.pname;
              inherit (envoy.apple-font) src;
              dontUnpack = true;
              dontBuild = true;
              dontConfigure = true;
              nativeBuildInputs = [ pkgs.rsync ];
              installPhase = ''
                mkdir -p $out/share/fonts/apple-nerd
                rsync -r --exclude='NY/*Black*' --exclude='NY/*Heavy*' ${finalAttrs.src}/ $out/share/fonts/apple-nerd
              '';
            }))
            (pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
              name = envoy.apple-font-emoji.pname;
              inherit (envoy.apple-font-emoji) src;
              dontUnpack = true;
              dontBuild = true;
              dontConfigure = true;
              installPhase = ''
                install -D -m644 $src $out/share/fonts/truetype/AppleColorEmoji-Linux.ttf
              '';
            }))
          ];
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
            serif = [ "SF Pro Display" ];
            sansSerif = [ "SF Pro Text" ];
            monospace = [ "LigaSFMono Nerd Font" ];
            emoji = [ "Apple Color Emoji" ];
          };
        };
      };
    };
}
