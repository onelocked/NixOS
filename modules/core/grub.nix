{
  envoy.grubTheme = {
    github = "onelocked/grub2-theme";
    locked = true;
  };
  m.default =
    { pkgs, envoy, ... }:
    {
      boot.loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
        timeout = 1;
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          useOSProber = true;
          gfxmodeEfi = "3440x1440";
          gfxmodeBios = "3440x1440";
          splashMode = "normal";
          splashImage = (
            pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/grubmeath.png";
              hash = "sha256-/OrtuIi3y4eihIF8FoBtjy+0ykTYRGA0uHyp0PAAu/o=";
            }
          );
          theme = pkgs.stdenv.mkDerivation {
            inherit (envoy.grubTheme) pname src version;
            installPhase = ''
              install -dm755 $out
              cp -rf theme/* $out/
            '';
          };
        };
      };
    };
}
