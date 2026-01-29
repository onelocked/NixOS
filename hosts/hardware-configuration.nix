{
  flake.modules.nixos.onelock =
    {
      config,
      lib,
      ...
    }:
    {
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      boot.kernelModules = [ "kvm-amd" ];

      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
