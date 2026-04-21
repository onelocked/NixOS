{ inputs, ... }:
{
  ff.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  m.default =
    { pkgs, ... }:
    {
      nix.settings = {
        substituters = [ "https://cache.garnix.io" ];
        trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
      };
      nixpkgs.overlays = [
        # Guarantees you have binary cache, but initializes another nixpkgs instance.
        inputs.nix-cachyos-kernel.overlays.pinned
      ];
      # boot.kernelPackages = pkgs.linuxPackages_latest; # _latest, _zen, _xanmod_latest, _hardened, _rt
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
    };
}
