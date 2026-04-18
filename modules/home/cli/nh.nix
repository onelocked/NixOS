{ self, ... }:
{
  flake.modules.nixos.nh = {
    programs.nh = {
      enable = true;
      flake = self.variables.homedir + "/NixOS";
      clean.enable = false;
      clean.extraArgs = "--keep-since 4d --keep 3";
    };
    environment.shellAliases = {
      nhs = "nh os switch -H NixOS";
    };
  };
}
