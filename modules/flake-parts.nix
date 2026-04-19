{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    (lib.mkAliasOptionModule [ "m" ] [ "flake" "modules" "nixos" ])
    inputs.flake-file.flakeModules.dendritic
  ];

  systems = [ "x86_64-linux" ];

  flake-file = {
    inputs.wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    do-not-edit = "";
    outputs = # nix
      "inputs: ./modules |> inputs.import-tree |> inputs.flake-parts.lib.mkFlake { inherit inputs; }";
    description = "onelock's dendritic nixos flake configuration";
    style = {
      sortPriority.inputs = [
        "nixpkgs"
        "flake-parts"
        "flake-file"
        "wrappers"
        "extra-modules"
      ];
    };
  };
}
