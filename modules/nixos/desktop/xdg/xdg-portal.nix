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
      xdg.portal = {
        config = {
          common = {
            default = mkForce [ "gnome" ];
            "org.freedesktop.impl.portal.Secret" = mkForce [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.Chooser" = mkForce [ "none" ];
          };
          niri = {
            default = mkForce [ "gnome" ];
            "org.freedesktop.impl.portal.Secret" = mkForce [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.Chooser" = mkForce [ "none" ];
          };
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
