{
  exo.core =
    { pkgs, ... }:
    {
      services = {
        scx = {
          enable = true;
          package = pkgs.scx.rustscheds;
          scheduler = "scx_cake"; # https://wiki.cachyos.org/configuration/sched-ext/#scx_cake
        };
      };
    };
}
