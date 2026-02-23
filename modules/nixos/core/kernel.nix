{
  flake.nixosModules.core =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_latest; # _latest, _zen, _xanmod_latest, _hardened, _rt
    };
}
