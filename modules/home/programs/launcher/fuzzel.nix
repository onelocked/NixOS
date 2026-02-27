{
  flake.homeModules.fuzzel =
    { config, pkgs, ... }:
    {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            include = "${config.xdg.configHome}" + "/fuzzel/themes/noctalia";
            dpi-aware = "yes";
            width = 25;
            letter-spacing = 0;
            font = "Liga SFMono:weight=500:style=Bold:width=expanded:size=15";
            namespace = "fuzzel";
            icon-theme = "${config.gtk.iconTheme.name}";
            terminal = "${pkgs.foot}/bin/foot -e";
          };
          border = {
            radius = 20;
          };
        };
      };

    };
}
