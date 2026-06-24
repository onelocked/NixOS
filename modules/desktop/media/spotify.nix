{ inputs, ... }:
{
  ff.spicetify-nix = {
    url = "github:Gerg-L/spicetify-nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.systems.follows = "systems";
  };

  exo.mods.desktop =
    {
      inputs',
      scheme,
      config,
      ...
    }:
    let
      spicePkgs = inputs'.spicetify-nix.legacyPackages;
    in
    {
      imports = [ inputs.spicetify-nix.nixosModules.default ];

      programs.spicetify = {
        enable = config.desktop.media.enable;
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
      forte.hyprland.lua.window-rules = # lua
        ''
          hl.window_rule({
            name      = "spotify",
            match     = { class = "Spotify" },
            workspace = "name:media silent",
          })
        '';
      forte.persist.home.directories = [ ".config/spotify" ];
    };
}
