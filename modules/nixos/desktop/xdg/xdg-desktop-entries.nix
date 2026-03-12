{
  flake.modules.homeManager.xdg =
    { pkgs, ... }:
    {
      xdg = {
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
          # "zen-twilight" = {
          #   name = "Zen Browser";
          #   icon = "zen-twilight";
          #   exec = "${pkgs.niri-launcher}/bin/niri-launcher zen-twilight zen-twilight";
          # };
          "org.jellyfin.JellyfinDesktop" = {
            name = "Jellyfin";
            icon = "org.jellyfin.JellyfinDesktop";
            exec = "${pkgs.jellyfin-desktop}/bin/jellyfin-desktop --platform xcb";
          };
          "jellyfin-tui" = {
            name = "jellyfin-tui";
            noDisplay = true;
          };
        };
      };
    };
}
