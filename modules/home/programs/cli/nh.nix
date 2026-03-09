{ self, ... }:
{
  flake.modules.homeManager.nh = {
    programs.nh = {
      enable = true;
      flake = self.variables.homedir + "/NixOS";
      clean.enable = false;
      clean.extraArgs = "--keep-since 4d --keep 3";
    };
    home.shellAliases = {
      nhs = "nh os switch -H NixOS";
    };
  };
}
