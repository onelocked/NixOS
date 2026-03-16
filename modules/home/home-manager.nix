{ self, ... }:
{
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
