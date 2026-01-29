{ config, ... }:
{
  networking = {
    hostName = "${config.constants.hostname}";
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
}
