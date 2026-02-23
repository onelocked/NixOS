{
  flake.nixosModules.desktop =
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
          "org.freedesktop.impl.portal.Secret" = mkForce [
            "gnome-keyring"
          ];
        };
        niri = {
          "org.freedesktop.impl.portal.Secret" = mkForce [
            "gnome-keyring"
          ];
        };
      };
      xdg.terminal-exec = {
        enable = true;
        settings = {
          default = [ "foot.desktop" ];
        };
      };
    };
}
