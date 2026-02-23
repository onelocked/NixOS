{
  flake.homeModules.theming =
    { pkgs, ... }:
    {
      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
      };
    };
}
