top@{ lib, ... }:
{
  config = {
    tack.inputs.base16 = "gh:SenchoPens/base16.nix";
    exo.skeleton =
      {
        config,
        inputs,
        pkgs,
        ...
      }:
      {
        options.scheme = lib.mkOption {
          type = lib.types.enum (lib.attrNames top.config.schemes);
          default = "dark";
          description = "Choose the system colorscheme.";
        };

        config._module.args.scheme = (inputs.base16.lib pkgs).mkSchemeAttrs (
          {
            slug = config.scheme;
            scheme = config.scheme;
            author = config.scheme;
          }
          // top.config.schemes.${config.scheme}
        );
      };
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
  };
  options.schemes = lib.mkOption {
    type = lib.types.attrsOf lib.types.attrs;
    description = "A set of base16/24 colorschemes";
  };
}
