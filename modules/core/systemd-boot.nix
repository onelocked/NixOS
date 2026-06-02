{
  m.default = {
    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 5;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
  };
}
