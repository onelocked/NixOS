{
  inputs,
  self,
  ...
}:
{
  flake-file = {
    inputs.hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  m.default =
    {
      lib,
      config,
      ...
    }:
    let
      inherit (self.variables) username homedir;
    in
    {
      imports = [
        inputs.hjem.nixosModules.default
        (lib.mkAliasOptionModule [ "hj" ] [ "hjem" "users" self.variables.username ])
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
