{ self, ... }:
{
  m.default =
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
            theme = pkgs.stdenv.mkDerivation {
              pname = "grub-theme";
              version = "v1.0";
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
}
