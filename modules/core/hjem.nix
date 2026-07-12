{ inputs, ... }:
{
  tack.hjem = "gh:feel-co/hjem";
  exo.core =
    {
      lib,
      config,
      constants,
      packages',
      ...
    }:
    {
      imports = [
        inputs.hjem.nixosModules.default
        (lib.mkAliasOptionModule [ "hj" ] [ "hjem" "users" constants.username ])
      ];
      hjem.linker = packages'.hjem.smfh;
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
