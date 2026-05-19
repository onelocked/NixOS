{
  m.default =
    { lib, pkgs, ... }:
    {
      services = {
        scx = {
          enable = true;
          package = pkgs.scx.rustscheds;
          scheduler = lib.mkDefault "scx_bpfland"; # scheduler that prioritizes interactive workloads  https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
        };
      };
    };
}
