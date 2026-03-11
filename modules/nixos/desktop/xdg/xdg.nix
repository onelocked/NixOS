{ self, ... }:
{
  flake.modules.homeManager.xdg = {
    xdg =
      let
        inherit (self.variables) homedir;
      in
      {
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
