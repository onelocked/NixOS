{
  exo.core =
    { pkgs, ... }:
    {
      services = {
        scx = {
          enable = true;
          package = pkgs.scx.rustscheds;
          scheduler = "scx_lavd"; # Gaming scheduler https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
        };
      };
    };
}
