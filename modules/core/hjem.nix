{ inputs, ... }:
{
  tack.inputs.hjem = "gh:feel-co/hjem";
  exo.core =
    {
      lib,
      config,
      constants,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.hjem.nixosModules.default
        (lib.mkAliasOptionModule [ "hj" ] [ "hjem" "users" constants.username ])
      ];
      hjem.linker = pkgs.smfh;
      hj = {
        enable = true;
        user = constants.username;
        directory = constants.homedir;
        clobberFiles = true;
        files.".profile" = {
          executable = true;
          source = config.hj.environment.loadEnv;
        };
      };
    };
}
