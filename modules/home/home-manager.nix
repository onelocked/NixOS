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
        sessionVariables = {
          EDITOR = "nvim";
        };
      };

      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
          download = homedir + "/Downloads";
          pictures = homedir + "/Pictures";
          videos = homedir + "/Videos";
          documents = homedir + "/Documents";
          extraConfig = {
            PROJECTS = homedir + "/Development";
          };
          desktop = null;
          music = null;
          publicShare = null;
          templates = null;
        };
      };
    };
}
