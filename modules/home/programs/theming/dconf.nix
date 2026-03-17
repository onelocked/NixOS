{
  flake = {
    modules = {
      homeManager.dconf =
        { config, ... }:
        {
          dconf.settings = {
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-theme = "${config.gtk.theme.name}";
            };
          };
        };
      nixos.desktop = {
        programs.dconf.enable = true;
      };
    };
  };
}
