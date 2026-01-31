{
  flake.modules.homeManager.theming =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.adw-gtk3
      ];
      # Enable dconf for home-manager
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
        };
      };
    };
}
