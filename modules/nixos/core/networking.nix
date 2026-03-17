{ self, ... }:
{
  flake.modules.nixos.default =
    { lib, ... }:
    let
      inherit (self.variables) hostname;
      inherit (lib) mkDefault;
    in
    {
      networking = {
        hostName = hostname;
        useDHCP = mkDefault true;
        networkmanager.enable = true;
        firewall.enable = false;
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
