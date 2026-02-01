{ self, inputs, ... }:
{
  flake.nixosConfigurations = {
    NixOS = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        with self.modules.nixos;
        [
          hardware
          amdgpu
          core
          desktop
          home-manager
          ghostty
        ]
        ++ [
          {
            home-manager.users.${self.variables.username} = {
              imports = with self.modules.homeManager; [
                state
                cli
                vicinae
                quickshell
                theming
                zen-browser
                media
                jellyfin-desktop
                ghostty
              ];
            };
          }
        ];
    };
  };
}
