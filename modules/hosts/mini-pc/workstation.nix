{ self, ... }:
with self.lib;
with self.modules.nixos;
{
  flake.nixosConfigurations.NixOS = mkSystem {
    modules = [
      hardware-mini-pc
      user
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
      kitty
      fish

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
