{
  exo.hardware.gaming-pc = {
    hardware.graphics = {
      enable = true;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;
      nvidiaSettings = true;
    };
    services.lact.enable = true;
    forte.persist.root.directories = [ "/etc/lact" ];
  };
}
