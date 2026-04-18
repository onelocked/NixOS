{
  m.default =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linux-cachyos-latest;
    };
}
