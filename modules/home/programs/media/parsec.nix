{
  flake.modules.nixos.parsec =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.parsec-bin ];
    };
}
