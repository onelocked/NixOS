{ inputs, ... }:
{
  exo.mods.desktop =
    {
      inputs',
      scheme,
      config,
      lib,
      ...
    }:
    let
      spicePkgs = inputs'.spicetify-nix.legacyPackages;
      cfg = config.programs.spicetify;
    in
    {
      imports = [ inputs.spicetify-nix.nixosModules.default ];
      config = lib.mkMerge [
        {
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
        }
        (lib.mkIf cfg.enable {
          forte.allowUnfree = [ "spotify" ];
          forte.hyprland.lua.window-rules =
            # lua
            ''
              hl.window_rule({
                name      = "spotify",
                match     = { class = "spotify" },
                workspace = "name:chat silent",
                scrolling_width = 0.5,
              })
            '';
          forte.persist.home.directories = [
            ".config/spotify"
            ".cache/spotify"
          ];
        })
      ];
    };
}
