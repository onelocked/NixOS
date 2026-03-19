{ self, ... }:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.default =
    let
      inherit (self.variables) username homedir stateVersion;
    in
    {

      home = {
        username = username;
        homeDirectory = homedir;
        stateVersion = stateVersion;
      };
    };
}
