{ self, inputs, ... }:
{
  flake.nixosConfigurations = {
    NixOS = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        with self.modules.nixos;
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
              imports = with self.modules.homeManager; [
                # Core modules
                default
                cli

                # Desktop Specific
                theming
                foot
                vicinae
                fuzzel
                quickshell
                zen-browser
                media
                jellyfin-desktop
                jellyfin-tui
                obs-studio
                mpv
                qview
                fish
                dott-tui
                worktrunk
              ];
            };
          }
        ];
    };
  };
}
