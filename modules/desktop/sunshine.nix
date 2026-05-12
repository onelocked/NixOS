{
  m.sunshine = {
    networking.firewall = {
      allowedTCPPorts = [
        47984
        47989
        47990
        48010
      ];
      allowedUDPPortRanges = [
        {
          from = 47998;
          to = 48000;
        }
      ];
    };
    services.sunshine = {
      enable = true;
      capSysAdmin = true;
      autoStart = false;
      openFirewall = true;
    };
  };
}
