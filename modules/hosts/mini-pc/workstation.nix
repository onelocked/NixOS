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
      core
      overlays
      desktop
    ];
    homeModules = with homeManager; [
      default
      cli
      tui
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
      worktrunk
    ];
  };
}
