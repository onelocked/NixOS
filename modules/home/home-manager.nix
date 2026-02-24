{
  self,
  inputs,
  ...
}:
{
  flake = {
    nixosModules = {
      home-manager =
        { pkgs, config, ... }:
        {
          imports = [
            inputs.home-manager.nixosModules.home-manager
          ];
          users = {
            defaultUserShell = pkgs.${self.variables.shell};
            users.${self.variables.username} = {
              isNormalUser = true;
              useDefaultShell = true;
              extraGroups = [
                "networkmanager"
                "wheel"
                "kvm"
                "input"
                "disk"
                "libvirtd"
                "video"
                "audio"
              ];
            };
          };

          environment.shells = [ config.users.defaultUserShell ]; # Default shell

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
          };
        };
    };

    homeModules.default = {
      home.username = self.variables.username;
      home.homeDirectory = self.variables.homedir;
      home.stateVersion = "25.11";
      home.sessionVariables = {
        EDITOR = "nvim";
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
