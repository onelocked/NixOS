{
  exo.core =
    { constants, ... }:
    {
      programs.nh = {
        enable = true;
        flake = constants.homedir + "/NixOS";
        clean.enable = false;
        clean.extraArgs = "--keep-since 4d --keep 3";
      };
    };
}
