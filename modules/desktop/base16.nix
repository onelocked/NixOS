{ inputs, ... }:
{
  ff.base16.url = "github:SenchoPens/base16.nix";

  m.desktop =
    { config, ... }:
    let
      cfg = config.forte.theme;
    in
    {
      imports = [ inputs.base16.nixosModule ];
      scheme = cfg.${cfg.variant};
      forte.theme.variant = "light";
      forte.theme = {
        light = {
          slug = "retroism";
          scheme = "retro";
          author = "onelock";

          # Background & UI Chrome
          base00 = "#d8d8d8";
          base01 = "#aaaaaa";
          base02 = "#bebebf";
          base03 = "#8c8c8c";

          # Foregrounds
          base04 = "#555555";
          base05 = "#252525";
          base06 = "#444444";
          base07 = "#111111";

          # Accents
          base08 = "#9e1c1c";
          base09 = "#9e4e00";
          base0A = "#6b6100";
          base0B = "#246628";
          base0C = "#005959";
          base0D = "#183871";
          base0E = "#5c2488";
          base0F = "#6b3a1f";

          # Extended
          base10 = "#cacaca";
          base11 = "#bcbcba";
          base12 = "#8e2a46";
          base13 = "#7a1830";
          base14 = "#22634e";
          base15 = "#0e5c6e";
          base16 = "#502888";
          base17 = "#782858";
        };
        dark = {
          slug = "onemeath";
          scheme = "Aemeath";
          author = "onelock";

          # Backgrounds
          base00 = "#131316";
          base01 = "#221c2c";
          base02 = "#313245";
          base03 = "#3d3050";

          # Foregrounds
          base04 = "#8c92aa";
          base05 = "#cfd3e7";
          base06 = "#e4e8f5";
          base07 = "#f0f2fa";

          # Accents
          base08 = "#f4a8b8";
          base09 = "#f2b8a0";
          base0A = "#f6d88a";
          base0B = "#b8db8c";
          base0C = "#7cb8d4";
          base0D = "#c5c0ff";
          base0E = "#c8b0e8";
          base0F = "#7d75c0";

          # Extended
          base10 = "#130f18";
          base11 = "#0c0a10";
          base12 = "#ff7a6b";
          base13 = "#f6d88a";
          base14 = "#c8e09c";
          base15 = "#8fd4b5";
          base16 = "#a8c8f0";
          base17 = "#e8c4d8";
        };
      };
      _module.args = { inherit (config) scheme; };
    };
  m.default =
    { lib, ... }:
    {
      options.forte.theme = {
        variant = lib.mkOption {
          type = lib.types.enum [
            "light"
            "dark"
          ];
          default = "light";
          description = "Choose between the light and dark theme variant.";
        };

        light = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Light theme options.";
        };

        dark = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Dark theme options.";
        };
      };
    };
}
