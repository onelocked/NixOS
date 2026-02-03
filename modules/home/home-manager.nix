{
  self,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.home-manager =
      { pkgs, ... }:
      {
        imports = [
          inputs.home-manager.nixosModules.home-manager
        ];
        users.users.${self.variables.username} = {
          isNormalUser = true;
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
        users.defaultUserShell = pkgs.nushell;
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
        };
      };

    homeManager.state = {
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
            XDG_PROJECTS_DIR = self.variables.homedir + "/Development";
            XDG_BIN_HOME = self.variables.homedir + "/.local/bin";
          };
        };
      };
    };
  };
}
