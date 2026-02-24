{ self, inputs, ... }:
{
  flake.nixosConfigurations = {
    NixOS = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        with self.nixosModules;
        [
          mini-pc
          onelock
          core
          desktop
          overlays
          home-manager
        ]
        ++ [
          {
            home-manager.users.${self.variables.username} = {
              imports = with self.homeModules; [
                default
                cli
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
