{ config, ... }:
{
  flake.nixosConfigurations.NixOS = config.forte.system.mkSystem {
    modules = with config.m; [
      onelock
      hardware-mini-pc
      user
      desktop
      sunshine
      niri
      opkssh

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

      worktrunk
      qview
      starship
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
    ];
  };
  m.onelock =
    let
      constants = {
        username = "onelock";
        homedir = "/home/onelock";
        hostname = "NixOS";
        locale = "en_GB.UTF-8";
        timezone = "Europe/London";
        stateVersion = "25.11";
      };
    in
    {
      _module.args = { inherit constants; };
    };
}
