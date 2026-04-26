{ inputs, ... }:
{
  ff = {
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  m.default =
    { pkgs, ... }:
    {
      nix.settings = {
        substituters = [
          "https://cache.garnix.io"
          "https://attic.xuyh0120.win/lantian"
        ];
        trusted-public-keys = [
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        ];
      };
      nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ]; # Guarantees you have binary cache, but initializes another nixpkgs instance.

      # boot.kernelPackages = pkgs.linuxPackages_latest; # _latest, _zen, _xanmod_latest, _hardened, _rt
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    };
}
