{ inputs, ... }:
{
  flake.modules.nixos.vicinae =
    { pkgs, ... }:
    {
      nix.settings = {
        extra-substituters = [ "https://vicinae.cachix.org" ];
        extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
      };

      imports = [
        inputs.vicinae.homeManagerModules.default
        {
          services.vicinae = {
            enable = true;
            package = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;
            systemd = {
              enable = true;
              autoStart = true;
              environment = {
                QT_SCALE_FACTOR = "1.5";
              };
            };
          };
        }
      ];
    };
}
