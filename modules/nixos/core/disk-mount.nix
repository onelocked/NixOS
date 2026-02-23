{
  flake.modules.nixos.core = {
    services = {
      devmon.enable = false;
      gvfs.enable = false;
      udisks2.enable = false;
    };
  };
}
