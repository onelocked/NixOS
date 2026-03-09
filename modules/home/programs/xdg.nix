{ self, ... }:
{
  flake.modules.homeManager.xdg =
    { pkgs, ... }:
    {
      xdg =
        let
          inherit (self.variables) homedir;
        in
        {
          enable = true;
          userDirs = {
            enable = true;
            createDirectories = true;
            download = homedir + "/Downloads";
            pictures = homedir + "/Pictures";
            videos = homedir + "/Videos";
            documents = homedir + "/Documents";
            extraConfig = {
              PROJECTS = homedir + "/Development";
            };
            desktop = null;
            music = null;
            publicShare = null;
            templates = null;
          };

          desktopEntries = {
            "yazi" = {
              name = "Yazi";
              noDisplay = true;
            };
            "qt5ct" = {
              name = "Qt5 Configuration Tool";
              noDisplay = true;
            };
            "qt6ct" = {
              name = "Qt6 Configuration Tool";
              noDisplay = true;
            };
            "footclient" = {
              name = "Foot Client";
              noDisplay = true;
            };
            "foot-server" = {
              name = "Foot Server";
              noDisplay = true;
            };
            "nixos-manual" = {
              name = "NixOS Manual";
              noDisplay = true;
            };
            "btop" = {
              name = "btop++";
              noDisplay = true;
            };
            "mpv" = {
              name = "MPV";
              exec = "${pkgs.mpv}/bin/mpv --player-operation-mode=pseudo-gui -- %U";
              icon = "mpv";
            };
            "umpv" = {
              name = "umpv Media Player";
              noDisplay = true;
            };
            "vicinae" = {
              name = "Vicinae";
              noDisplay = true;
            };
            "nvim" = {
              name = "Neovim Wrapper";
              noDisplay = true;
            };
            "zen-twilight" = {
              name = "Zen Browser";
              icon = "zen-twilight";
              exec = "${pkgs.niri-launcher}/bin/niri-launcher zen-twilight zen-twilight";
            };
          };
        };
    };
}
