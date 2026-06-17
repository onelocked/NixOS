{
  exo.mods.desktop =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.forte.jellyfin-tui;
    in
    {
      config = lib.mkIf cfg.enable {
        forte.persist.home.directories = [
          ".local/share/jellyfin-tui"
        ];
        forte.xdg.desktopEntries."jellyfin-tui".noDisplay = true;
        hj = {
          packages = [ pkgs.jellyfin-tui ];
          xdg.config.files."jellyfin-tui/config.yaml".text = # yaml
            ''
              keymap_inherit: true
              servers:
              - name: Jellyfish
                quick_connect: true
                url: https://jellyfin.onelock.org

              keymap:
                ctrl-c: Quit
                Ctrl-Right: !Seek 5
                Ctrl-Left: !Seek -5
                left: PreviousPane
                right: NextPane
                =: VolumeUp
            '';
        };
      };
      options.forte.jellyfin-tui = {
        enable = lib.mkEnableOption "jellyfin-tui";
      };
    };
}
