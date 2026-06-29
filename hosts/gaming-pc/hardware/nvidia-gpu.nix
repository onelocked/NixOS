{
  exo.hardware.gaming-pc = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      branch = "bleeding_edge";
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
    };
    services.lact.enable = true;
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
    boot.kernelModules = [ "ntsync" ];
    forte.persist.root.directories = [ "/etc/lact" ];
  };
}
