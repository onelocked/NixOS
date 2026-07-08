{ inputs, ... }:
{
  ff.hjem = {
    url = "github:feel-co/hjem";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  exo.core =
    {
      lib,
      config,
      constants,
      inputs',
      ...
    }:
    {
      imports = [
        inputs.hjem.nixosModules.default
        (lib.mkAliasOptionModule [ "hj" ] [ "hjem" "users" constants.username ])
      ];
      hjem.linker = inputs'.hjem.packages.smfh;
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
