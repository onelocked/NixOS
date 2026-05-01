{ config, ... }:
{
  flake.nixosConfigurations.NixOS = config.forte.system.mkSystem {
    modules = with config.m; [
      onelock
      hardware-mini-pc
      user
      desktop
      sunshine
      opkssh
      hyprland

      rtp-audio
      otter-launcher

      btop
      bat
      direnv
      fastfetch
      git
      lla
      nh
      fzf

      quickshell

      starship
      kitty
      fish

      vesktop

      spotify

      mpv
      yazi

      neovim

      qt

      zen-browser
    ];
  };
}
