{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      services = {
        system76-scheduler = {
          enable = true;
          useStockConfig = true;
        };
        scx = {
          enable = true;
          package = pkgs.scx.rustscheds;
          scheduler = "scx_lavd"; # https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
        };
      };
    };
}
