{
  exo.core =
    { lib, ... }:
    let
      inherit (lib) mkForce;
    in
    {
      services = {
        printing.enable = mkForce false;
        xserver.enable = mkForce false;
        dbus.implementation = mkForce "broker";
        journald = {
          storage = "persistent";
          extraConfig = ''
            SystemMaxUse=500M
            SystemKeepFree=1G
            SystemMaxFileSize=50M
            MaxRetentionSec=1month
          '';
        };
      };
    };
}
