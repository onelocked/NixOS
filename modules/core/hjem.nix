{ inputs, ... }:
{
  ff.hjem = {
    url = "github:feel-co/hjem";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.nix-darwin.follows = "";
  };

  exo.core =
    {
      lib,
      config,
      constants,
      inputs',
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
      hjem.linker = inputs'.hjem.packages.smfh;
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
