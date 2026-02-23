{
  flake.nixosModules.desktop = {
    services.sunshine = {
      enable = true;
      capSysAdmin = true;
      autoStart = false;
      openFirewall = true;
    };
  };
}
