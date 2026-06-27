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
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
    forte.persist.root.directories = [ "/etc/lact" ];
  };
}
