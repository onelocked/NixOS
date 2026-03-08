{
  flake.modules.homeManager.parsec =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.parsec-bin ];
    };
}
