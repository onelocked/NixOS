{ inputs, ... }:
{
  flake-file.inputs.worktrunk = {
    url = "github:max-sixty/worktrunk/fe395cb467d341d4b21e9b1cc6cfa2feaec0fdd1";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.worktrunk = {
    imports = [ inputs.worktrunk.homeModules.default ];
    programs.worktrunk = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
