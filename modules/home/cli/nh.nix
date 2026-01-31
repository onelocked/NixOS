{ inputs, self, ... }:
let
  inherit (inputs.wrappers.lib) wrapPackage;
in
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:

    let
      wrapped-nh = wrapPackage {
        inherit pkgs;
        package = pkgs.nh;
        env = {
          "NH_OS_FLAKE" = self.variables.homedir + "/NixOS";
        };
      };
    in
    {
      programs.nh = {
        enable = true;
        package = wrapped-nh;
        clean.enable = false;
        clean.extraArgs = "--keep-since 4d --keep 3";
      };
      home.shellAliases = {
        nhs = "nh os switch -H onelock";
      };
    };
}
