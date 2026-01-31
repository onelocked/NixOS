{ self, inputs, ... }:
{
  flake.nixosConfigurations = {
    NixOS = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        with inputs.self.modules.nixos;
        [
          hardware
          amdgpu
          core
          desktop
          home-manager
        ]
        ++ [
          {
            home-manager.users.${self.variables.username} = {
              imports = with inputs.self.modules.homeManager; [
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
