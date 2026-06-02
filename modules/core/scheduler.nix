{
  m.default =
    { lib, pkgs, ... }:
    {
      services = {
        system76-scheduler = {
          enable = true;
          useStockConfig = true;
        };
        scx = {
          enable = false;
          package = pkgs.scx.rustscheds;
          scheduler = lib.mkForce "scx_lavd"; # Gaming scheduler https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
        };
      };
    };
}
