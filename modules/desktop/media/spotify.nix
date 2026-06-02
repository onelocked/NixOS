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
          accent = base0E;
          accent-active = base0D;
          accent-inactive = base03;
          banner = base0D;
          border-active = base0F;
          border-inactive = base01;
          header = base04;
          highlight = base03;
          main = base00;
          notification = base16;
          notification-error = base08;
          subtext = base04;
          text = base05;
        };
        enabledExtensions = with spicePkgs.extensions; [
          adblock
          hidePodcasts
        ];
      };
      forte.niri.settings.window-rules = [
        {
          matches = [ { app-id = "Spotify"; } ];
          open-on-workspace = "media";
          open-focused = false;
          open-fullscreen = false;
        }
      ];
    };
}
