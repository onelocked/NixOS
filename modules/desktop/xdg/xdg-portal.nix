{
  exo.mods.desktop =
    { lib, constants, ... }:
    {
      xdg = {
        portal = {
          enable = true;
          xdgOpenUsePortal = false;
          wlr.enable = false;
          config = {
            common = {
              default = lib.mkForce [ "gtk" ];
              "org.freedesktop.impl.portal.Secret" = lib.mkForce [ "gnome-keyring" ];
              "org.freedesktop.impl.portal.Chooser" = lib.mkForce [ "none" ];
              "org.freedesktop.impl.portal.AppChooser" = lib.mkForce [ "none" ];
            };
          };
        };
        terminal-exec = {
          enable = true;
          settings = {
            default = [ constants.terminal ];
          };
        };
      };
      environment.sessionVariables = {
        GTK_USE_PORTAL = "0";
      };
    };
}
