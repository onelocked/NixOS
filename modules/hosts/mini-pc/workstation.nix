{ self, ... }:
let
  inherit (self.lib) mkSystem;
  inherit (self.modules) nixos;
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
      opkssh

      #ported stuff
      btop
      bat
      direnv
      fastfetch
      git
      lla
      nh

      quickshell

      worktrunk
      qview
      jellyfin-tui
      starship
      foot
      fish

      obs-studio

      cursor
      vesktop

      spotify

      mpv
      yazi

      neovim
      vicinae

      gtk
      qt

      zen-browser
    ];
  };
}
