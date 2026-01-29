{ config,lib, ... }:
{
  networking = {
    hostName = "${config.constants.hostname}";
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
}
