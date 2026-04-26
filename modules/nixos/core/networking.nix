{ self, ... }:
{
  m.default =
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
        firewall.enable = true;
        interfaces.eno1.wakeOnLan.enable = true;
      };
      # TCP fq optimisation
      boot = {
        kernelModules = [ "tcp_bbr" ];
        kernel.sysctl = {
          "net.ipv4.tcp_congestion_control" = "bbr";
          "net.core.default_qdisc" = "cake"; # or "cake" for newer kernels
        };
      };

      services.avahi = {
        enable = true;
        publish.enable = true;
        openFirewall = true;
        nssmdns4 = true;
      };
    };
}
