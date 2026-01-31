{
  self,
  inputs,
  ...
}:
{
  flake.modules.nixos.home-manager =
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
      home-manager.users.${self.variables.username} = {
        imports = with inputs.self.modules.homeManager; [
          xdg
          cli
          vicinae
          quickshell
          theming
          zen-browser
          media
          jellyfin-desktop
          ghostty
        ];
        home.username = self.variables.username;
        home.homeDirectory = self.variables.homedir;
        home.stateVersion = "25.11";
        home.sessionVariables = {
          EDITOR = "nvim";
        };
      };
    };
}
