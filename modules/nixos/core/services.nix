{
  flake.nixosModules.core =
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
      };
      programs.seahorse.enable = mkForce false;
    };
}
