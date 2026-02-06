{ self, ... }:
{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      boot = {
        tmp.cleanOnBoot = true;
        supportedFilesystems = [
          "ntfs"
          "exfat"
          "ext4"
          "fat32"
          "btrfs"
        ];
        kernelPackages = pkgs.linuxPackages_latest; # _latest, _zen, _xanmod_latest, _hardened, _rt, _OTHER_CHANNEL, etc.
        loader = {
          efi.canTouchEfiVariables = true;
          efi.efiSysMountPoint = "/boot";
          timeout = 5; # Display bootloader indefinitely until user selects OS
          grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            useOSProber = true;
            gfxmodeEfi = "3440x1440";
            gfxmodeBios = "3440x1440";
            splashMode = "normal";
            splashImage = "${self.variables.homedir}/Pictures/grub.png";
            theme = pkgs.stdenv.mkDerivation {
              pname = "grub-theme-wuwa";
              version = "unstable-2025-07-09";
              src = pkgs.fetchFromGitHub {
                owner = "onelocked";
                repo = "grub2-theme";
                rev = "207dfe09411f08916666acf65bf6262e5ef5e6d0";
                hash = "sha256-ChnML4zm4EnVX/WmZW5RWHnK/tqjXSeR4BK8XfN0xxA=";
              };
              installPhase = ''
                install -dm755 $out
                cp -rf theme/* $out/
              '';
            };
          };
        };
      };
    };
}
