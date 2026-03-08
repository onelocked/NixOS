{
  flake.modules.homeManager.qt =
    {
      lib,
      config,
      ...
    }:
    let
      qtctConf = {
        Appearance = {
          color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/noctalia.conf";
          custom_palette = true;
          icon_theme = config.gtk.iconTheme.name;
          standard_dialogs = "default";
          style = "Fusion";
        };
      };
      defaultFont = "${config.gtk.font.name},12";
    in
    {
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "Fusion";
      };

      xdg.configFile = {

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
