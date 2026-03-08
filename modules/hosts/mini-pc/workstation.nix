{ self, ... }:
let
  inherit (self.lib) mkSystem;
  inherit (self.modules) nixos homeManager;
in
{
  flake.nixosConfigurations.NixOS = mkSystem {
    nixosModules = with nixos; [
      hardware-mini-pc
      user
      overlays
      desktop
    ];
    homeModules = with homeManager; {
      shell = [
        shell-default
        fish
        starship
      ];
      cli = [
        cli-default
        bat
        btop
        direnv
        fastfetch
        git
        nh
        worktrunk
      ];
      tui = [
        tui-default
        zellij
        yazi
        dott-tui
      ];
      desktop = [
        foot
        quickshell
        zen-browser
        qview
        theming
      ];
      launcher = [
        fuzzel
        vicinae
      ];
      media = [
        media-default
        mpv
        obs-studio
        jellyfin-desktop
        jellyfin-tui
      ];
    };
  };
}
