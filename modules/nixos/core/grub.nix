{ self, ... }:
{
  flake.nixosModules.core =
    { pkgs, ... }:
    {
      boot.loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
        timeout = 5;
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          useOSProber = true;
          gfxmodeEfi = "3440x1440";
          gfxmodeBios = "3440x1440";
          splashMode = "normal";
          splashImage = "${self.variables.homedir}/Pictures/grub.png";
          theme = pkgs.grub-theme;
        };
      };
    };
}
