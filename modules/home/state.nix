{ self, ... }:
{
  flake.modules.homeManager.state = {

    home.username = self.variables.username;
    home.homeDirectory = self.variables.homedir;
    home.stateVersion = "25.11";
    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
