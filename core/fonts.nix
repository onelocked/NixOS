{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      apple-nerd-fonts
      material-symbols
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontDir.enable = true;
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "medium";
        autohint = false;
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      defaultFonts = {
        serif = [ "SF Pro Display" ];
        sansSerif = [ "SF Pro Text" ];
        monospace = [ "LigaSFMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
