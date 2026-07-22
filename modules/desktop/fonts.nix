{
  exo.mods.desktop =
    { pkgs, self', ... }:
    {
      fonts = {
        packages = with pkgs; [
          nerd-fonts.symbols-only
          montserrat
          maple-mono.NF
          self'.legacyPackages.apple-fonts
        ];
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
            monospace = [ "Maple Mono NF" ];
            emoji = [ "Apple Color Emoji" ];
          };
        };
      };
    };
  perSystem =
    { pkgs, inputs, ... }:
    let
      makeAppleFont =
        name: pkgName: src:
        pkgs.stdenvNoCC.mkDerivation {
          allowSubstitutes = false;
          preferLocalBuild = true;

          inherit name src;

          unpackPhase = # bash
            ''
              7z x $src
              7z x './*/${pkgName}'
              7z x 'Payload~'
            '';

          nativeBuildInputs = [ pkgs.p7zip ];

          setSourceRoot = "sourceRoot=`pwd`";

          installPhase = # bash
            ''
              find . -name '*.otf' -exec install -Dm644 -t "$out/share/fonts/opentype" {} +
              find . -name '*.ttf' -exec install -Dm644 -t "$out/share/fonts/truetype" {} +
            '';
        };
    in
    {
      legacyPackages = {
        apple-fonts =
          let
            fonts = {
              sf-pro = makeAppleFont "sf-pro" "SF Pro Fonts.pkg" inputs.sf-pro;
              sf-mono = makeAppleFont "sf-mono" "SF Mono Fonts.pkg" inputs.sf-mono;
              sf-compact = makeAppleFont "sf-compact" "SF Compact Fonts.pkg" inputs.sf-compact;
              emoji = pkgs.stdenvNoCC.mkDerivation {
                allowSubstitutes = false;
                preferLocalBuild = true;

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
          in
          pkgs.symlinkJoin {
            name = "apple-fonts";
            paths = builtins.attrValues fonts;
            passthru = fonts;
          };
      };
    };
  tack.inputs = {
    sf-pro = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      fixed = true;
    };
    sf-mono = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
      fixed = true;
    };
    sf-compact = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
      fixed = true;
    };
    apple-font-emoji = {
      url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/macos-26-20260613-f1fc560b/AppleColorEmoji-Linux.ttf";
      fixed = true;
    };
  };
}
