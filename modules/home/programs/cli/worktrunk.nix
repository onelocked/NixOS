{ inputs, ... }:
{
  flake.homeModules.worktrunk = {
    imports = [ inputs.worktrunk.homeModules.default ];
    programs.worktrunk = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
