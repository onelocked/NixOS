{ self, ... }:
with self.lib;
with self.modules.nixos;
{
  flake.nixosConfigurations.NixOS = mkSystem {
    modules = [
      hardware-mini-pc
      user
      overlays
      desktop
      sunshine
      niri
      opkssh

      btop
      bat
      direnv
      fastfetch
      git
      lla
      nh
      fzf

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
      tmux
    ];
  };
}
