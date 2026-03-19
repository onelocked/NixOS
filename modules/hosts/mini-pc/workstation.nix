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
      sunshine
      niri
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
        neovim
      ];
      desktop = [
        xdg
        foot
        quickshell
        zen-browser
      ];
      theming = [
        gtk
        qt
        dconf
        cursor
        matugen
      ];
      launcher = [
        vicinae
      ];
      media = [
        spotify
        mpv
        obs-studio
        qview
        jellyfin-desktop
        jellyfin-tui
        telegram-desktop
        vesktop
        parsec
        moonlight-qt
      ];
    };
  };
}
