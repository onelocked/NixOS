{ lib, ... }:
{
  m.qt =
    { config, pkgs, ... }:
    let
      qtctConf = {
        Appearance = {
          color_scheme_path = config.hj.xdg.config.directory + "/qt6ct/colors/noctalia.conf";
          custom_palette = true;
          icon_theme = config.custom.gtk.iconTheme.name;
          standard_dialogs = "default";
          style = "Fusion";
        };
      };
      defaultFont = "${config.custom.gtk.font.name},12";
    in
    {
      environment = {
        systemPackages = with pkgs.qt6Packages; [
          qt6ct
          qtwayland
        ];
      };

      # use gtk theme on qt apps
      qt = {
        enable = true;
        platformTheme = "qt5ct";
        style = "adwaita-dark";
      };

      # use dynamic theme for qt5ct.conf and qt6ct.conf
      hj.xdg.config.files =
        let
          default = ''"${defaultFont},-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
        in
        {
          "qt5ct/qt5ct.conf".text = lib.generators.toINI { } (
            qtctConf
            // {
              Fonts = {
                fixed = default;
                general = default;
              };
            }
          );
          "qt6ct/qt6ct.conf".text = lib.generators.toINI { } (
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
