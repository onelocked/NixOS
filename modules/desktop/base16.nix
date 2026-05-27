{ inputs, ... }:
{
  ff.base16.url = "github:SenchoPens/base16.nix";

  m.desktop =
    { config, ... }:
    {
      imports = [ inputs.base16.nixosModule ];

      _module.args = {
        inherit (config) scheme;
      };
    };
  m.default = {
    scheme = {
      slug = "onemeath";
      scheme = "Aemeath";
      author = "onelock";

      # Backgrounds
      base00 = "#1a1520"; # Default background
      base01 = "#221c2c"; # Lighter background
      base02 = "#2e2438"; # Selection background
      base03 = "#3d3050"; # Comments, invisibles

      # Foregrounds
      base04 = "#8c92aa"; # Dark foreground
      base05 = "#cfd3e7"; # Default foreground
      base06 = "#e4e8f5"; # Light foreground
      base07 = "#f0f2fa"; # Lightest foreground

      # Accents
      base08 = "#f4a8b8"; # Red
      base09 = "#f2b8a0"; # Orange
      base0A = "#f6d88a"; # Yellow
      base0B = "#b8db8c"; # Green
      base0C = "#7cb8d4"; # Cyan
      base0D = "#7d75c0"; # Blue
      base0E = "#c8b0e8"; # Mauve
      base0F = "#c5c0ff"; # Lavender

      # Extended
      base10 = "#130f18"; # Darker background
      base11 = "#0c0a10"; # Darkest background
      base12 = "#ff7a6b"; # Bright red
      base13 = "#f6d88a"; # Bright yellow
      base14 = "#c8e09c"; # Bright green
      base15 = "#8fd4b5"; # Bright cyan
      base16 = "#a8c8f0"; # Bright blue
      base17 = "#e8c4d8"; # Bright magenta
    };
  };
}
