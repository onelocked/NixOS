{ self, ... }:
{
  flake.modules.homeManager.settings = {
    home.username = self.variables.username;
    home.homeDirectory = self.variables.homedir;
    home.stateVersion = "25.11";
    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
