{
  flake.modules.nixos.default =
    { lib, pkgs, ... }:
    {
      services = {
        system76-scheduler = {
          enable = true;
          useStockConfig = true;
        };
        scx = {
          enable = true;
          package = pkgs.scx.rustscheds;
          scheduler = lib.mkDefault "scx_lavd"; # Gaming scheduler https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
        };
      };
    };
}
