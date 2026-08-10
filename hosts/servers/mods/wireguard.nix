{
  exo.mods.amneziawg =
    { config, ... }:
    {
      services.fail2ban = {
        enable = true;
        bantime = "24h";
        maxretry = 3;
        ignoreIP = [
          "127.0.0.0/8"
          "10.0.0.0/8"
          "192.168.0.0/16"
        ];
        jails = {
          sshd.settings = {
            mode = "aggressive";
          };
        };
      };
      networking.firewall.allowedUDPPorts = [ 51820 ];
      networking.nat = {
        enable = true;
        externalInterface = "ens3";
        internalInterfaces = [ "awg0" ];
      };

      sops.secrets."wg_server_private_key" = { };
      sops.secrets."wg_peer1" = { };
      sops.secrets."wg_peer2" = { };
      sops.secrets."wg_peer3" = { };

      networking.wireguard.interfaces = {
        wg0 = {
          ips = [ "10.10.50.1/24" ];
          listenPort = 51820;
          mtu = 1420;
          privateKeyFile = config.sops.secrets."wg_server_private_key".path;

          peers = [
            {
              # Peer 1
              publicKey = "s87owok1M++3TV17zZxvtL/s1KsV+mLzvkJ5Ld/fKmM=";
              presharedKeyFile = config.sops.secrets."wg_peer1".path;
              allowedIPs = [ "10.10.50.2/32" ];
            }
            {
              # Peer 2
              publicKey = "6yBFO2K/KCcXI9w2UP4oDFNVbwYOQfBpt4IhULMy2ko=";
              presharedKeyFile = config.sops.secrets."wg_peer2".path;
              allowedIPs = [ "10.10.50.3/32" ];
            }
            {
              # Peer 3
              publicKey = "MzyGMmOIunCy24LqGcezP4tix8wd1tOblXl5m6dUowI=";
              presharedKeyFile = config.sops.secrets."wg_peer3".path;
              allowedIPs = [ "10.10.50.4/32" ];
            }
          ];
        };
      };
    };
}
