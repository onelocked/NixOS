{ inputs, ... }:
{
  flake.modules.homeManager.vicinae =
    { pkgs, ... }:
    let
      vicinae-unstable = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      imports = [ inputs.vicinae.homeManagerModules.default ];
      nix.settings = {
        extra-substituters = [ "https://vicinae.cachix.org" ];
        extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
      };

      services.vicinae = {
        enable = true;
        package = vicinae-unstable;
        systemd = {
          enable = true;
          autoStart = true;
          environment = {
            QT_SCALE_FACTOR = "1.5";
          };
        };
      };
    };
}
