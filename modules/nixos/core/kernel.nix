{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      nix.settings = {
        substituters = [
          "https://cache.garnix.io"
        ];
      };
      boot.kernelPackages = pkgs.linux-cachyos-latest;
    };
}
