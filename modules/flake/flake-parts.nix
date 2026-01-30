{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.home-manager.flakeModules.home-manager
  ];
  systems = [ "x86_64-linux" ];
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;
      packages = (import ../../pkgs) { inherit pkgs; };
    };
}
