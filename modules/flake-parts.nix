{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-file.flakeModules.dendritic
  ];

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake-file = {
    do-not-edit = "";
    description = "onelock's dendritic nixos flake configuration";
    style = {
      sortPriority.inputs = [
        "nixpkgs"
        "flake-parts"
        "flake-file"
        "home-manager"
        "wrappers"
        "extra-modules"
      ];
    };
  };
}
