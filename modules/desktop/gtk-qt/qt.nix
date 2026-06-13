{
  exo.mods.desktop =
    {
      config,
      pkgs,
      lib,
      scheme,
      ...
    }:
    let
      iniFmt = (pkgs.formats.ini { }).generate;

      qtctConf = {
        Appearance = {
          color_scheme_path = colorSchemeFile;
          custom_palette = true;
          icon_theme = config.forte.gtk.icons.name;
          standard_dialogs = "default";
          style = "Adwaita-Dark";
        };
        Fonts = {
          fixed = font;
          general = font;
        };
      };

      font = ''"${config.forte.gtk.font.serif},12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';

      qtctFile.source = iniFmt "qtct.conf" qtctConf;

      palette =
        with scheme.withHashtag;
        "${base07}, ${base00}, #ffffff, #cacaca, #9f9f9f, #b8b8b8, ${base07}, #ffffff, ${base07}, ${base00}, ${base00}, #000000, ${base0D}, ${base06}, ${base05}, ${base0F}, ${base03}, ${base00}, ${base03}, ${base07}, ${base07}, ${base0F}";
      colorSchemeFile = iniFmt "colors.conf" {
        ColorScheme =
          [
            "active_colors"
            "disabled_colors"
            "inactive_colors"
          ]
          |> (names: lib.genAttrs names (_: palette));
      };
    in
    {
      environment = {
        systemPackages = with pkgs.qt6Packages; [
          qt6ct
          qtwayland
        ];
        sessionVariables = {
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        };
      };

      forte.xdg.desktopEntries = {
        "qt5ct".noDisplay = true;
        "qt6ct".noDisplay = true;
      };

      qt = {
        enable = true;
        platformTheme = "qt5ct";
        style = "adwaita-dark";
      };

      hj.xdg.config.files = {
        "qt5ct/qt5ct.conf" = qtctFile;
        "qt6ct/qt6ct.conf" = qtctFile;
      };
    };
}
