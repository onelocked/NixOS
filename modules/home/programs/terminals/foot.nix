{
  flake.modules.homeManager.foot = {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          include = "~/.config/foot/themes/noctalia";

          font = "Maple Mono NL NF:style=ExtraBold:size=13";
          font-bold = "SFMono Nerd Font:style=Heavy:size=13";
          font-italic = "SF Mono:style=Bold Italic:size=13";
          font-bold-italic = "SF Mono:style=Heavy Italic:size=13";

          pad = "8x3x8x0";
          dpi-aware = "yes";
          bold-text-in-bright = "no";
          gamma-correct-blending = "no";
        };

        scrollback = {
          lines = 10000;
        };

        cursor = {
          style = "block";
          unfocused-style = "hollow";
          blink = "yes";
          blink-rate = 500;
          underline-thickness = 3;
        };

        mouse = {
          hide-when-typing = "yes";
        };

        mouse-bindings = {
          select-extend = "none";
          clipboard-copy = "BTN_RIGHT";
        };

        tweak = {
          render-timer = "none";
          overflowing-glyphs = "yes";
          font-monospace-warn = "no";
          surface-bit-depth = "8-bit";
        };
      };
    };
  };
}
