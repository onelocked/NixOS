{ self, ... }:
let
  inherit (self.lib) mkSystem;
  inherit (self.modules) nixos homeManager;
in
{
  flake.nixosConfigurations.NixOS = mkSystem {
    nixosModules = with nixos; [
      mini-pc
      onelock
      core
      overlays
      home-manager
      desktop
    ];
    homeModules = with homeManager; [
      default
      cli
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
