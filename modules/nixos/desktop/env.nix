{ self, ... }:
{
  flake.nixosModules.desktop =
    { config, ... }:
    let
      cfg = config.home-manager.users.${self.variables.username};
    in
    {
      environment.sessionVariables = {
        QS_ICON_THEME = "${cfg.gtk.iconTheme.name}";
        GTK_USE_PORTAL = "1";
      };
    };
}
