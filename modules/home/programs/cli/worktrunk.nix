{ inputs, ... }:
{
  flake.modules.homeManager.worktrunk = {
    imports = [ inputs.worktrunk.homeModules.default ];
    programs.worktrunk = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
