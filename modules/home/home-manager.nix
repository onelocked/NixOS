{
  flake.modules.homeManager.onelock =
    { config, ... }:
    {
      home.username = "${config.variables.username}";
      home.homeDirectory = "/home/${config.variables.username}";
      home.stateVersion = "25.11";
      home.sessionVariables = {
        EDITOR = "nvim";
      };
      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
          download = "home/onelock/Downloads";
          pictures = "/home/onelock/Pictures";
          videos = "/home/onelock/Videos";
          documents = "/home/onelock/Documents";
          desktop = null;
          music = null;
          publicShare = null;
          templates = null;
          extraConfig = {
            XDG_PROJECTS_DIR = "/home/onelock/Development";
            XDG_BIN_HOME = "/home/onelock/.local/bin";
          };
        };
      };
    };
}
