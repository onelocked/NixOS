{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.home-manager.flakeModules.home-manager
  ];
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;
      packages = (import ../pkgs) { inherit pkgs; };
    };
}
