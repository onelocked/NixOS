{ inputs, ... }:
{
  flake-file.inputs.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release"; # WARN:Do not override its nixpkgs input, otherwise there can be mismatch between patches and kernel version

  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      nix.settings = {
        substituters = [
          "https://attic.xuyh0120.win/lantian"
          "https://cache.garnix.io"
        ];
        trusted-public-keys = [
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };

      nixpkgs.overlays = [
        # Guarantees you have binary cache, but initializes another nixpkgs instance.
        inputs.nix-cachyos-kernel.overlays.pinned
      ];
      # boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest; # boot.kernelPackages = pkgs.linuxPackages_latest; # _latest, _zen, _xanmod_latest, _hardened, _rt
    };
}
