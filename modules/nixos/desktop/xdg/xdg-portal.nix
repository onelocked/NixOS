{ self, ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, lib, ... }:
    let
      inherit (lib) mkForce;
    in
    {
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-termfilechooser
        ];
        xdgOpenUsePortal = true;
        wlr.enable = false;
      };
      xdg.portal.config = {
        common = {
          "org.freedesktop.impl.portal.FileChooser" = mkForce [
            "termfilechooser"
          ];
          "org.freedesktop.impl.portal.Secret" = mkForce [
            "gnome-keyring"
          ];
        };
        niri = {
          "org.freedesktop.impl.portal.FileChooser" = mkForce [
            "termfilechooser"
          ];
          "org.freedesktop.impl.portal.Secret" = mkForce [
            "gnome-keyring"
          ];
        };
      };
      xdg.terminal-exec = {
        enable = true;
        settings = {
          default = [ "ghostty.desktop" ];
        };
      };
      home-manager.sharedModules = [
        {
          xdg.configFile = {
            "xdg-desktop-portal-termfilechooser/config".text = ''
              [filechooser]
              cmd=yazi-wrapper.sh
              default_dir=${self.variables.homedir}/Downloads
              open_mode=suggested
              save_mode=default
            '';
            "xdg-desktop-portal-termfilechooser/yazi-wrapper.sh".source = ../../../../scripts/yazi-wrapper.sh;
          };
        }
      ];
    };
}
