{
  flake.modules.homeManager.foot = {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          include = "~/.config/foot/themes/noctalia";

          font = "Liga SFMono:style=Bold:size=12";
          font-bold = "Liga SFMono:style=Heavy:size=12";
          font-italic = "Liga SFMono:style=Bold Italic:size=12";
          font-bold-italic = "Liga SFMono:style=Heavy Italic:size=12";

          pad = "6x6";
          dpi-aware = "yes";
        };

        cursor = {
          style = "beam";
          blink = "yes";
          blink-rate = 500;
          beam-thickness = 1.5;
        };

        mouse = {
          hide-when-typing = "no";
        };

        tweak = {
          render-timer = "none";
          overflowing-glyphs = "yes";
          font-monospace-warn = "no";
        };
      };
    };
  };
}
