{ self, ... }:
{
  flake.modules.homeManager.onelock = {
    home.username = self.variables.username;
    home.homeDirectory = self.variables.homedir;
    home.stateVersion = "25.11";
    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
