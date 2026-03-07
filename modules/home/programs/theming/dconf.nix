{
  flake = {
    modules.homeManager.theming =
      { config, ... }:
      {
        # Enable dconf for home-manager
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = "${config.gtk.theme.name}";
          };
        };
      };
    modules.nixos.desktop = {
      programs.dconf.enable = true;
    };
  };
}
