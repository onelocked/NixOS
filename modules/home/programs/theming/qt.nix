{
  flake.modules.homeManager.theming =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      KvLibadwaita = pkgs.fetchFromGitHub {
        owner = "GabePoel";
        repo = "KvLibadwaita";
        rev = "1f4e0bec44b13dabfa1fe4047aa8eeaccf2f3557";
        hash = "sha256-32RlnRBNJajD0Ps+vZSwVfDj6HzPpZjfm/LBG7u0eDg=";
        sparseCheckout = [ "src" ];
      };

      qtctConf = {
        Appearance = {
          color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/noctalia.conf";
          custom_palette = true;
          icon_theme = config.gtk.iconTheme.name;
          standard_dialogs = "default";
          style = "kvantum";
        };
      };

      defaultFont = "${config.gtk.font.name},12";
    in
    {
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";
      };

      xdg.configFile = {
        # Kvantum config
        "Kvantum" = {
          source = "${KvLibadwaita}/src";
          recursive = true;
        };

        # see home/services/system/theme.nix for kvantum config

        # qtct config
        "qt5ct/qt5ct.conf".text =
          let
            default = ''"${defaultFont},-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
          in
          lib.generators.toINI { } (
            qtctConf
            // {
              Fonts = {
                fixed = default;
                general = default;
              };
            }
          );

        "qt6ct/qt6ct.conf".text =
          let
            default = ''"${defaultFont},-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
          in
          lib.generators.toINI { } (
            qtctConf
            // {
              Fonts = {
                fixed = default;
                general = default;
              };
            }
          );
      };
    };
}
