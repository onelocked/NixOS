{ self, inputs, ... }:
{
  flake.nixosConfigurations = {
    NixOS = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        with self.nixosModules;
        [
          mini-pc # Hardware configuration
          onelock # user configuration
          core # core nixos modules
          overlays
          home-manager

          desktop
        ]
        ++ [
          {
            home-manager.users.${self.variables.username} = {
              imports = with self.homeModules; [
                # Core modules
                default
                cli

                # Desktop Specific
                theming
                foot
                vicinae
                quickshell
                zen-browser
                media
                jellyfin-desktop
                obs-studio
                mpv
                qview
              ];
            };
          }
        ];
    };
  };
}
