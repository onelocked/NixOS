{
  flake.homeModules.jellyfin-tui = {
    xdg.configFile."jellyfin-tui/config.yaml".text = # yaml
      ''
        servers:
        - name: Jellyfish
          quick_connect: true
          url: https://jellyfin.onelock.org

        keymap_inherit: true

        keymap:
          ctrl-c: Quit
          Ctrl-Right: !Seek 5
          Ctrl-Left: !Seek -5

          left: PreviousPane
          right: NextPane
          =: VolumeUp
      '';
  };
}
