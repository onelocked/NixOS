{
  flake.modules.nixos.sunshine = {
    services.sunshine = {
      enable = true;
      capSysAdmin = true;
      autoStart = false;
      openFirewall = true;
    };
  };
}
