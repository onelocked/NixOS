{
  envoy.grubTheme.github = "onelocked/grub2-theme";
  m.default =
    {
      pkgs,
      envoy,
      constants,
      ...
    }:
    {
      boot.loader =
        let
          inherit (constants) homedir;
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
