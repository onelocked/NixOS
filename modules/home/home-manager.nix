{ self, ... }:
{
  flake.modules.homeManager.default = {
    home = {
      username = self.variables.username;
      homeDirectory = self.variables.homedir;
      stateVersion = self.variables.stateVersion;
      sessionVariables = {
        EDITOR = "nvim";
      };
    };

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        download = self.variables.homedir + "/Downloads";
        pictures = self.variables.homedir + "/Pictures";
        videos = self.variables.homedir + "/Videos";
        documents = self.variables.homedir + "/Documents";
        desktop = null;
        music = null;
        publicShare = null;
        templates = null;
        extraConfig = {
          PROJECTS = self.variables.homedir + "/Development";
        };
      };
    };
  };
}
