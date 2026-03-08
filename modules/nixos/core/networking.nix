{ self, ... }:
{
  flake.modules.nixos.core =
    { lib, ... }:
    {
      networking =
        let
          inherit (self.variables) hostname;
          inherit (lib) mkDefault;
        in
        {
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
