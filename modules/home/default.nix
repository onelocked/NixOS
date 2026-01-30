{ inputs, ... }:
{
  flake.modules.nixos.home-manager =
    { config, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.${config.variables.username} = {
          home.username = "${config.variables.username}";
          home.homeDirectory = "/home/${config.variables.username}";
          home.sessionVariables = {
            EDITOR = "nvim";
          };
          xdg = {
            enable = true;
            userDirs = {
              enable = true;
              createDirectories = true;
              download = config.home.homeDirectory + "/Downloads";
              pictures = config.home.homeDirectory + "/Pictures";
              videos = config.home.homeDirectory + "/Videos";
              documents = config.home.homeDirectory + "/Documents";
              desktop = null;
              music = null;
              publicShare = null;
              templates = null;
              extraConfig = {
                XDG_PROJECTS_DIR = config.home.homeDirectory + "/Development";
                XDG_BIN_HOME = config.home.homeDirectory + "/.local/bin";
              };
            };
          };
        };
      };
    };
}
