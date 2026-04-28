{ inputs, ... }:
{
  ff.hjem = {
    url = "github:feel-co/hjem";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  m.default =
    {
      lib,
      config,
      constants,
      ...
    }:
    let
      inherit (constants) username homedir;
    in
    {
      imports = [
        inputs.hjem.nixosModules.default
        (lib.mkAliasOptionModule [ "hj" ] [ "hjem" "users" constants.username ])
      ];
      hjem = {
        clobberByDefault = true;
      };
      hj = {
        enable = true;
        user = username;
        directory = homedir;
        clobberFiles = true;
        files.".profile" = {
          executable = true;
          source = config.hj.environment.loadEnv;
        };
      };
    };
}
