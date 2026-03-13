{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          apple-font
          nerd-fonts.symbols-only
          noto-fonts-color-emoji
          maple-mono.NL-NF
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
