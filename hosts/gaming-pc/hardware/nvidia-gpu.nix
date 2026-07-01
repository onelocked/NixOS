{
  exo.hardware.gaming-pc = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    hardware.nvidia = {
      branch = "bleeding_edge";
      modesetting.enable = true;
      open = true;
      nvidiaSettings = false;
    };
    services.xserver.videoDrivers = [ "nvidia" ]; # needed to  have nviida drivers enabled
    forte.allowUnfree = [ "nvidia-x11" ];

    services.lact.enable = true; # GPU fan control GUI with a daemon

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    boot.kernelModules = [ "ntsync" ]; # support driver for emulation of NT synchronization, used by Wine/Proton
    forte.persist.root.directories = [ "/etc/lact" ];
  };
}
