{
  flake.modules.nixos.jellyfin-tui =
    { pkgs, ... }:
    {
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
}
