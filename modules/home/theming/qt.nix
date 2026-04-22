{ lib, ... }:
{
  m.qt =
    { config, pkgs, ... }:
    let
      iniFmt = (pkgs.formats.ini { }).generate;

      qtctConf = {
        Appearance = {
          color_scheme_path = colorSchemeFile;
          custom_palette = true;
          icon_theme = config.custom.gtk.iconTheme.name;
          standard_dialogs = "default";
          style = "Adwaita-Dark";
        };
        Fonts = {
          fixed = font;
          general = font;
        };
      };

      font = ''"${config.custom.gtk.font.name},12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';

      qtctFile.source = iniFmt "qtct.conf" qtctConf;

      palette = "#e5e1e6, #131316, #ffffff, #cacaca, #9f9f9f, #b8b8b8, #e5e1e6, #ffffff, #e5e1e6, #131316, #131316, #000000, #413b8e, #e3dfff, #c7c4dc, #c5c0ff, #47464f, #131316, #47464f, #e5e1e6, #e5e1e6, #c5c0ff";
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
      environment.systemPackages = with pkgs.qt6Packages; [
        qt6ct
        qtwayland
      ];

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
