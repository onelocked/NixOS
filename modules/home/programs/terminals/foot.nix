{
  flake.modules.homeManager.foot = {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          include = "~/.config/foot/themes/noctalia";

          font = "SFMono Nerd Font:style=Bold:size=12";
          font-bold = "SFMono Nerd Font:style=Heavy:size=12";
          font-italic = "SFMono Nerd Font:style=Bold Italic:size=12";
          font-bold-italic = "SFMono Nerd Font:style=Heavy Italic:size=12";

          pad = "6x6";
          dpi-aware = "yes";
          bold-text-in-bright = "no";
          gamma-correct-blending = "no";
        };

        scrollback = {
          lines = 10000;
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

        mouse-bindings = {
          select-extend = "none";
          clipboard-copy = "BTN_RIGHT";
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
