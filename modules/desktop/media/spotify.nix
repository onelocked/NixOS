{ inputs, ... }:
{
  ff.spicetify-nix = {
    url = "github:Gerg-L/spicetify-nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.systems.follows = "systems";
  };

  m.spotify =
    { inputs', scheme, ... }:
    let
      spicePkgs = inputs'.spicetify-nix.legacyPackages;
    in
    {
      imports = [ inputs.spicetify-nix.nixosModules.default ];

      programs.spicetify = {
        enable = true;
        theme = spicePkgs.themes.text;
        customColorScheme = with scheme; {
          accent = base0E; # #c8b0e8
          accent-active = base0F; # #c5c0ff
          accent-inactive = base03; # #3d3050
          banner = base0D; # #7d75c0
          border-active = base0F; # #c5c0ff
          border-inactive = base01; # #221c2c
          header = base04; # #8c92aa
          highlight = base03; # #3d3050
          main = base00; # #131316
          notification = base16; # #a8c8f0
          notification-error = base08; # #f4a8b8
          subtext = base04; # #8c92aa
          text = base05; # #cfd3e7
        };
        enabledExtensions = with spicePkgs.extensions; [
          adblock
          hidePodcasts
        ];
      };
      forte.niri.settings.window-rules = [
        {
          matches = [ { app-id = "spotify"; } ];
          open-on-workspace = "media";
          open-focused = false;
          open-fullscreen = false;
        }
      ];
    };
}
