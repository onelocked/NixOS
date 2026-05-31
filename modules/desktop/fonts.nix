{
  m.desktop =
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
            serif = [ "SF Pro Display" ];
            sansSerif = [ "New York" ];
            monospace = [ "LigaSFMono Nerd Font" ];
            emoji = [ "Apple Color Emoji" ];
          };
        };
      };
    };
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
  perSystem =
    { pkgs, envoy, ... }:
    {
      legacyPackages = {
        apple-font = pkgs.stdenvNoCC.mkDerivation {
          name = envoy.apple-font.pname;
          inherit (envoy.apple-font) src;
          dontUnpack = true;
          dontBuild = true;
          dontConfigure = true;
          installPhase = ''
            mkdir -p $out/share/fonts/apple-nerd
            ${pkgs.rsync}/bin/rsync -r --exclude='NY/*Black*' --exclude='NY/*Heavy*' $src/ $out/share/fonts/apple-nerd
          '';
        };
        apple-font-emoji = pkgs.stdenvNoCC.mkDerivation {
          name = envoy.apple-font-emoji.pname;
          inherit (envoy.apple-font-emoji) src;
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
