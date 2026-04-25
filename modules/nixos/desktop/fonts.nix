{
  m.desktop =
    { pkgs, ... }:
    let
      apple-font = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
        name = "apple-font";
        src = fetchTarball {
          url = "https://s3.onelock.org/download/fonts/apple-nerd.tar.gz";
          sha256 = "0ra0rv5cfw6gcdqam370g69afybbagqfyg03lf1l05m2bs3cpr29";
        };

        nativeBuildInputs = [ pkgs.rsync ];

        installPhase = ''
          mkdir -p $out/share/fonts/apple-nerd
          rsync -r --exclude='NY/*Black*' --exclude='NY/*Heavy*' ${finalAttrs.src}/ $out/share/fonts/apple-nerd
        '';
      });
    in
    {
      fonts = {
        packages = with pkgs; [
          apple-font
          nerd-fonts.symbols-only
          noto-fonts-color-emoji
          montserrat
          maple-mono.NF
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
            emoji = [ "Noto Color Emoji" ];
          };
        };
      };
    };
}
