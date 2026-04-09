{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      services = {
        scx = {
          enable = true;
          package = pkgs.scx.rustscheds;
          scheduler = "scx_bpfland"; # Best overall for normal workloads https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
        };
      };
    };
}
