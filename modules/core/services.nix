{
  exo.core =
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
        dbus.implementation = mkForce "broker";
        flatpak.enable = mkForce false;
      };
      programs.seahorse.enable = true;
      forte.persist = {
        home.directories = [
          ".local/share/keyrings"
        ];
      };
    };
}
