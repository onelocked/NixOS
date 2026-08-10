{
  exo.core =
    { lib, server, ... }:
    {
      networking = {
        useDHCP = false; # needs to be disabled to avoid conflict with systemd networking
        firewall.enable = true;
        networkmanager.enable = false;
      };

      # enable systemd networking
      services.resolved.enable = true;
      systemd.network = {
        enable = true;
        wait-online.enable = false;
        networks.wired = {
          matchConfig.Name = "en* eth*";
          networkConfig.DHCP = "yes";
        };
      };

      services.avahi = lib.mkIf (!server) {
        enable = true;
        publish.enable = true;
        openFirewall = true;
        nssmdns4 = true;
      };

      # TCP fq optimisation
      boot = {
        kernelModules = [ "tcp_bbr" ];
        kernel.sysctl = {
          "net.ipv4.tcp_congestion_control" = "bbr";
          "net.core.default_qdisc" = "cake";
        };
      };
    };
}
