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
        fish
        starship
      ];
      cli = [
        bat
        btop
        direnv
        fastfetch
        git
        nh
        worktrunk
      ];
      tui = [
        zellij
        yazi
        dott-tui
      ];
      desktop = [
        foot
        quickshell
        zen-browser
        theming
      ];
      launcher = [
        fuzzel
        vicinae
      ];
      media = [
        mpv
        obs-studio
        qview
        jellyfin-desktop
        jellyfin-tui
        telegram-desktop
        vesktop
        parsec
      ];
    };
  };
}
