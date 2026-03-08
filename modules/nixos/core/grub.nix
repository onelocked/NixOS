{ self, ... }:
{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      boot.loader =
        let
          inherit (self.variables) homedir;
        in
        {
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
            splashImage = homedir + "/Pictures/grub.png";
            theme = pkgs.grub-theme;
          };
        };
    };
}
