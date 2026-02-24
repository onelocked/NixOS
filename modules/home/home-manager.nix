{
  self,
  inputs,
  ...
}:
{
  flake = {
    nixosModules = {
      home-manager = {
        imports = [ inputs.home-manager.nixosModules.home-manager ];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
        };
      };
    };

    homeModules.default = {
      home = {
        username = self.variables.username;
        homeDirectory = self.variables.homedir;
        stateVersion = "25.11";
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
  };
}
