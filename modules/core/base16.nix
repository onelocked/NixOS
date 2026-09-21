{ lib, ... }:
{
  config = {
    schemes = {
      light = {
        # Backgrounds
        base00 = "#F4EAE1";
        base01 = "#e0d8ce";
        base02 = "#C4B09E";
        base03 = "#8a8078";

        # Foregrounds (Grey
        base04 = "#4a4640";
        base05 = "#1c1a18";
        base06 = "#1c1a18";
        base07 = "#000000";

        # Accents
        base08 = "#b04030";
        base09 = "#A65D3C";
        base0A = "#7a6a50";
        base0B = "#5C7457";
        base0C = "#5a4a30";
        base0D = "#8E4D2F";
        base0E = "#9a6830";
        base0F = "#8B7D6F";

        # Extended (Brights
        base10 = "#C2185B"; # Magenta
        base11 = "#D81B60"; # Pink
        base12 = "#4527A0"; # Clear Purple
        base13 = "#283593"; # Indigo
        base14 = "#0277BD"; # Cerulean
        base15 = "#00695C"; # Pine
        base16 = "#558B2F"; # Olive
        base17 = "#4E342E"; # Deep Coffee
      };
      dark = {
        # Backgrounds
        base00 = "#131316";
        base01 = "#221c2c";
        base02 = "#313245";
        base03 = "#4D415F";

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
    _module.args =
      let
        #
        # This serves as a highly stripped down base16.nix that has no dependency on pkgs
        #
        # This does not support loading files, and instead of withHashtag I have inverted this to noHashtag
        #
        # much of the following code is directly lifted or adapted from here:
        #   https://github.com/SenchoPens/base16.nix/blob/75ed5e5e3fce37df22e49125181fa37899c3ccd6/lib/colors.nix
        primaryHex2Dec =
          hex:
          let
            hex2decDigits = rec {
              "0" = 0;
              "1" = 1;
              "2" = 2;
              "3" = 3;
              "4" = 4;
              "5" = 5;
              "6" = 6;
              "7" = 7;
              "8" = 8;
              "9" = 9;
              A = 10;
              B = 11;
              C = 12;
              D = 13;
              E = 14;
              F = 15;
              a = A;
              b = B;
              c = C;
              d = D;
              e = E;
              f = F;
            };
          in
          16 * hex2decDigits."${builtins.substring 0 1 hex}" + hex2decDigits."${builtins.substring 1 1 hex}";

        hexToRgb = hex: {
          r = primaryHex2Dec (builtins.substring 0 2 hex);
          g = primaryHex2Dec (builtins.substring 2 2 hex);
          b = primaryHex2Dec (builtins.substring 4 2 hex);
        };

        ensureBase24 =
          scheme:
          {
            base10 = scheme.base00;
            base11 = scheme.base00;
            base12 = scheme.base08;
            base13 = scheme.base0A;
            base14 = scheme.base0B;
            base15 = scheme.base0C;
            base16 = scheme.base0D;
            base17 = scheme.base0E;
          }
          // scheme;

        addMnemonicNames =
          scheme:
          {
            red = scheme.base08;
            orange = scheme.base09;
            yellow = scheme.base0A;
            green = scheme.base0B;
            cyan = scheme.base0C;
            blue = scheme.base0D;
            magenta = scheme.base0E;
            brown = scheme.base0F;
            bright-red = scheme.base12;
            bright-yellow = scheme.base13;
            bright-green = scheme.base14;
            bright-cyan = scheme.base15;
            bright-blue = scheme.base16;
            bright-magenta = scheme.base17;
          }
          // scheme;

        round =
          float: # 4.2
          let
            int = builtins.floor float; # 4
            decimal = float - int; # 4.2 - 4 = 0.2
          in
          if decimal < 0.5 then int else builtins.ceil float;

        stripHashtag = lib.removePrefix "#";
      in
      {
        averageColors =
          {
            startColor,
            endColor,
            steps ? 1.0,
          }:
          let
            startRgb = hexToRgb (stripHashtag startColor);
            endRgb = hexToRgb (stripHashtag endColor);

            deltas = {
              r = startRgb.r - endRgb.r;
              g = startRgb.g - endRgb.g;
              b = startRgb.b - endRgb.b;
            };

            partials = deltas |> lib.mapAttrs (_: c: c / (steps + 1.0));
          in
          steps
          |> builtins.genList (
            i: startRgb |> lib.mapAttrs (n: v: lib.trivial.toHexString (round (v + ((i + 1) * partials.${n}))))
          )
          |> map (v: "#${v.r}${v.g}${v.b}");

        mkScheme =
          schema:
          let
            scheme = schema |> ensureBase24 |> addMnemonicNames;
            noHashtag = scheme |> lib.mapAttrs (_: v: stripHashtag v);
            asRgb8 = noHashtag |> lib.mapAttrs (_: v: hexToRgb v);
            asRgb = asRgb8 |> lib.mapAttrs (_: rgb: lib.mapAttrs (_: c: c / 256.0) rgb);
          in
          scheme // { inherit noHashtag asRgb8 asRgb; };
      };
  };
  options.schemes = lib.mkOption {
    type = lib.types.attrsOf lib.types.attrs;
    description = "A set of base16/24 colorschemes";
  };
}
