{ self, ... }:
{
  flake.nixosModules.core =
    { lib, ... }:
    {
      networking = {
        hostName = "${self.variables.hostname}";
        useDHCP = lib.mkDefault true;
        networkmanager.enable = true;
        firewall = {
          enable = false;
        };
        interfaces.eno1.wakeOnLan.enable = true;
      };
      services.avahi = {
        enable = true;
        publish.enable = true;
        openFirewall = true;
        nssmdns4 = true;
      };
    };
}
