{
  flake.modules.nixos.core =
    { ... }:
    {
      services.blueman.enable = false;
      hardware.bluetooth = {
        enable = false;
        powerOnBoot = false;
        settings.General.Experimental = true;
      };
    };
}
