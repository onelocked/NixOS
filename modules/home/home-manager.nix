{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules = {
    home-manager =
      { pkgs, ... }:
      {
        imports = [
          inputs.home-manager.nixosModules.home-manager
        ];
        users.users.${self.variables.username} = {
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
        # Default shell
        environment.shells = [ pkgs.${self.variables.shell} ];
        users.defaultUserShell = pkgs.${self.variables.shell};
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
        };
      };
  };

  flake.modules.homeManager.state = {
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
}
