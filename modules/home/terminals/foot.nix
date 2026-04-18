{
  m.foot =
    { pkgs, ... }:
    {
      hj = {
        xdg.config.files."foot/foot.ini".text = # ini
          ''
            [cursor]
            blink=yes
            blink-rate=500
            style=block
            underline-thickness=3
            unfocused-style=hollow

            [main]
            bold-text-in-bright=no
            dpi-aware=yes
            font=Maple Mono NL NF:style=ExtraBold:size=13
            font-bold=SFMono Nerd Font:style=Heavy:size=13
            font-bold-italic=SF Mono:style=Heavy Italic:size=13
            font-italic=SF Mono:style=Bold Italic:size=13
            gamma-correct-blending=no
            include=/home/onelock/.config/foot/themes/noctalia
            pad=8x3x8x0

            [mouse]
            hide-when-typing=yes

            [mouse-bindings]
            clipboard-copy=BTN_RIGHT
            select-extend=none

            [scrollback]
            lines=10000

            [tweak]
            font-monospace-warn=no
            overflowing-glyphs=yes
            render-timer=none
            surface-bit-depth=8-bit
          '';
        packages = [ pkgs.foot ];
      };
    };
}
