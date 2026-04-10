{
  flake.modules.nixos.default =
    { lib, ... }:
    let
      inherit (lib) mkForce;
    in
    {
      services = {
        printing.enable = mkForce false;
        gnome.gnome-keyring.enable = true;
        xserver.enable = mkForce false;
        journald.storage = "volatile";
        dbus.implementation = "broker";
        flatpak.enable = mkForce false;
      };
      programs.seahorse.enable = mkForce false;
    };
}
