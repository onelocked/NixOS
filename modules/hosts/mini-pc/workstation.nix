{ self, inputs, ... }:
{
  flake.nixosConfigurations = {
    NixOS = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        with self.nixosModules;
        [
          mini-pc
          grub
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
                custom-derivations
                cli
                zellij
                vicinae
                quickshell
                theming
                zen-browser
                media
                jellyfin-desktop
                foot
              ];
            };
          }
        ];
    };
  };
}
