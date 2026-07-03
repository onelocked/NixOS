{ config, ... }:
{
  exo.configurations = {
    gaming-pc = {
      user = "onelock";
      hardware = "gaming-pc";
      modules = with config.exo.mods; [
        desktop
        gaming
      ];
      extraConfig =
        {
          pkgs,
          lib,
          config,
          ...
        }:
        {
          desktop.media.enable = false;
          forte = {
            quickshell.enable = false;
            flatpak.enable = true;
            openssh.enable = true;
            nfs-share.enable = true;
            hyprland.lua.settings = # lua
              ''
                hl.on("hyprland.start", function()
                  hl.dispatch(hl.dsp.exec_raw("${lib.getExe' pkgs.awww "awww-daemon"}"))
                end)
                -- Restore wallpaper on monitor reconnect
                hl.on("monitor.added", function()
                  hl.dispatch(hl.dsp.exec_raw("${pkgs.awww}/bin/awww img ${config.hj.directory}/Pictures/wallpaper.png "))
                end)
              '';
          };
        };
    };
  };
}
