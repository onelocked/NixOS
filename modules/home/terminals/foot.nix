{ inputs, ... }:
{
  m.foot =
    { pkgs, config, ... }:
    {

      nixpkgs.overlays = [
        (_: prev: {
          foot = inputs.wrappers.wrappers.foot.wrap {
            pkgs = prev;
            inherit (config.custom.programs.foot) settings;
          };
        })
      ];
      hj.packages = [ pkgs.foot ];
      custom.programs.foot.settings = {
        main = {
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
        colors-dark = {
          background = "131316";
          foreground = "e5e1e6";

          selection-background = "ebb9d0";
          selection-foreground = "472538";

          regular0 = "47464f";
          regular1 = "f38ba8";
          regular2 = "a6e3a1";
          regular3 = "c7c4dc";
          regular4 = "ebb9d0";
          regular5 = "c5c0ff";
          regular6 = "c7c4dc";
          regular7 = "e5e1e6";

          bright0 = "c8c5d0";
          bright1 = "ffb4ab";
          bright2 = "c5c0ff";
          bright3 = "c7c4dc";
          bright4 = "ebb9d0";
          bright5 = "c5c0ff";
          bright6 = "c7c4dc";
          bright7 = "e5e1e6";
        };
      };
    };
  m.default =
    { pkgs, lib, ... }:
    {
      options.custom.programs.foot =
        let
          iniFmt = pkgs.formats.ini { };
        in
        {
          settings = lib.mkOption {
            inherit (iniFmt) type;
            default = { };
            description = ''
              Configuration of foot terminal.
              See {manpage}`foot.ini(5)`
            '';
          };
        };
    };
}
