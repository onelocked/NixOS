{
  m.fuzzel =
    {
      pkgs,
      config,
      birdee,
      ...
    }:
    {
      hj.packages = [ pkgs.fuzzel ];
      nixpkgs.overlays = [
        (_: prev: {
          fuzzel = birdee.wrappers.fuzzel.wrap {
            package = prev.fuzzel;
            pkgs = prev;
            settings = {
              main = {
                dpi-aware = "yes";
                width = 25;
                letter-spacing = 0;
                font = "Liga SFMono:weight=500:style=Bold:width=expanded:size=15";
                namespace = "fuzzel";
                icon-theme = "${config.custom.gtk.iconTheme.name}";
                terminal = "${pkgs.foot}/bin/foot -e";
              };
              colors = {
                background = "131316CC";
                text = "e5e1e6ff";
                prompt = "c7c4dcff";
                placeholder = "ebb9d0ff";
                input = "c5c0ffff";
                match = "ebb9d0ff";
                selection = "c5c0ff80";
                selection-text = "e5e1e6ff";
                selection-match = "2a2277ff";
                counter = "c7c4dcff";
                border = "c5c0ffff";
              };
            };
          };
        })
      ];
    };
}
