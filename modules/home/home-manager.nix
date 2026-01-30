{ self, ... }:
{
  flake.modules.homeManager.onelock =
    {
      lib,
      ...
    }:
    {
      home.username = self.variables.username;
      home.homeDirectory = lib.mkDefault "/home/onelock";
      home.stateVersion = "25.11";
      home.sessionVariables = {
        EDITOR = "nvim";
      };
    };
}
